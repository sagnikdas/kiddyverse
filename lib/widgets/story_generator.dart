// story_generator.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../pages/manage_profiles_page.dart';
import '../secrets.dart';
import '../models/child_profile.dart';
import '../models/story.dart';
import '../utils/preferences.dart';

class StoryGenerator extends StatefulWidget {
  const StoryGenerator({super.key});

  @override
  State<StoryGenerator> createState() => _StoryGeneratorState();
}

class _StoryGeneratorState extends State<StoryGenerator> {
  final TextEditingController _promptController = TextEditingController();
  String _story = "";
  bool _isLoading = false;

  final List<String> emotions = ["Happy", "Sleepy", "Curious"];
  final List<String> settings = ["Space", "Forest", "Ocean"];

  String selectedEmotion = "Happy";
  String selectedSetting = "Forest";

  ChildProfile? selectedChild;
  List<ChildProfile> children = [];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(ChildProfileAdapter());
    Hive.registerAdapter(StoryAdapter());

    final childBox = await Hive.openBox<ChildProfile>('childrenBox');
    final defaultChildId = Preferences.getDefaultChildId();

    setState(() {
      children = childBox.values.toList();
      if (children.isNotEmpty) {
        selectedChild = defaultChildId != null
            ? children.firstWhere((c) => c.id == defaultChildId, orElse: () => children.first)
            : children.first;
      }
      _updatePromptText();
    });
  }

  void _updatePromptText() {
    _promptController.text =
    "Write a short, kid-friendly story for a 4-year-old. The story should make the child feel $selectedEmotion. Set the story in a $selectedSetting environment. Include friendly characters and a fun, magical experience.";
  }

  Future<void> _generateStory() async {
    setState(() {
      _isLoading = true;
      _story = "";
    });

    final prompt = _promptController.text;

    const apiUrl = "https://api.openai.com/v1/chat/completions";
    final headers = {
      "Authorization": "Bearer $openAiApiKey",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "You are a creative and friendly storyteller for children."
        },
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.8
    });

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      final data = jsonDecode(response.body);
      final storyText = data["choices"][0]["message"]["content"];

      setState(() {
        _story = storyText;
      });

      if (selectedChild != null) {
        final storyBox = await Hive.openBox<Story>('storiesBox_${selectedChild!.id}');
        final story = Story(
          prompt: prompt,
          content: storyText,
          timestamp: DateTime.now(),
        );
        await storyBox.add(story);
      }
    } catch (e) {
      setState(() {
        _story = "Oops! Something went wrong: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildChoiceChips(List<String> options, String selected, void Function(String) onSelected, Color color) {
    return Wrap(
      spacing: 10,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: color,
          backgroundColor: Colors.grey.shade200,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (children.length > 1)
            DropdownButton<ChildProfile>(
              value: selectedChild,
              items: children.map((child) {
                return DropdownMenuItem(
                  value: child,
                  child: Text("${child.avatar ?? "👧"} ${child.name}"),
                );
              }).toList(),
              onChanged: (newChild) {
                setState(() {
                  selectedChild = newChild;
                });
              },
            ),
          const SizedBox(height: 10),
          const Text(
            "Choose an emotion:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildChoiceChips(emotions, selectedEmotion, (val) {
            setState(() {
              selectedEmotion = val;
              _updatePromptText();
            });
          }, Colors.pinkAccent),
          const SizedBox(height: 20),
          const Text(
            "Choose a setting:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildChoiceChips(settings, selectedSetting, (val) {
            setState(() {
              selectedSetting = val;
              _updatePromptText();
            });
          }, Colors.lightBlue),
          const SizedBox(height: 20),
          const Text(
            "Edit your story prompt:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Your story prompt will appear here",
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generateStory,
            child: const Text("Generate Story"),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: SingleChildScrollView(
              child: Text(
                _story,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
