import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kiddyverse/models/child_profile.dart';
import 'package:kiddyverse/models/story.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoryGeneratorPage extends StatefulWidget {
  const StoryGeneratorPage({super.key});

  @override
  State<StoryGeneratorPage> createState() => _StoryGeneratorPageState();
}

class _StoryGeneratorPageState extends State<StoryGeneratorPage> {
  final List<String> emotions = ['Happy', 'Sleepy', 'Curious'];
  final List<String> settings = ['Space', 'Forest', 'Ocean'];
  final TextEditingController _promptController = TextEditingController();

  String? selectedEmotion;
  String? selectedSetting;
  String? generatedStory;
  bool isLoading = false;
  ChildProfile? activeChild;

  final String openAiKey = 'YOUR_OPENAI_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _loadActiveChild();
  }

  void _loadActiveChild() {
    final prefsBox = Hive.box<String>('prefsBox');
    final childrenBox = Hive.box<ChildProfile>('childrenBox');
    final defaultId = prefsBox.get('defaultChildId');
    if (defaultId != null) {
      activeChild = childrenBox.get(defaultId);
    }
    setState(() {});
  }

  Future<void> _generateStory() async {
    if (_promptController.text.trim().isEmpty) return;
    setState(() => isLoading = true);

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $openAiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'user',
            'content': _promptController.text.trim(),
          }
        ],
        'max_tokens': 500,
      }),
    );

    final data = jsonDecode(response.body);
    final story = data['choices'][0]['message']['content'];

    setState(() {
      generatedStory = story;
      isLoading = false;
    });

    if (activeChild != null) {
      final storyBox = Hive.box<Story>('storiesBox');
      final newStory = Story(
        id: const Uuid().v4(),
        prompt: _promptController.text.trim(),
        generatedText: story,
        timestamp: DateTime.now(),
        childId: activeChild!.id,
      );
      storyBox.put(newStory.id, newStory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate a Story'),
        backgroundColor: Colors.orangeAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orangeAccent),
              child: Text('KiddyVerse Menu', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manage Profiles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage-profiles');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (activeChild != null)
              Text("👧 Story for: ${activeChild!.name}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const Text("Select Emotion", style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 10,
              children: emotions.map((emotion) {
                return ChoiceChip(
                  label: Text(emotion),
                  selected: selectedEmotion == emotion,
                  onSelected: (_) {
                    setState(() => selectedEmotion = emotion);
                    _composePrompt();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text("Choose Setting", style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 10,
              children: settings.map((setting) {
                return ChoiceChip(
                  label: Text(setting),
                  selected: selectedSetting == setting,
                  onSelected: (_) {
                    setState(() => selectedSetting = setting);
                    _composePrompt();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _promptController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Edit or add your own story idea",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _generateStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Generate Story"),
            ),
            const SizedBox(height: 30),
            if (generatedStory != null) ...[
              const Text("Generated Story:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(generatedStory!),
            ]
          ],
        ),
      ),
    );
  }

  void _composePrompt() {
    if (selectedEmotion != null && selectedSetting != null) {
      _promptController.text =
      "Tell me a $selectedEmotion story set in the $selectedSetting for a child aged ${activeChild?.age ?? 5}.";
    }
  }
}
