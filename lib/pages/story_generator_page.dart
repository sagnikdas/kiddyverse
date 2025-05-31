import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:kiddyverse/models/story.dart';
import 'package:kiddyverse/models/child_profile.dart';
import 'package:kiddyverse/services/openai_service.dart';
import 'package:kiddyverse/utils/child_utils.dart';

class StoryGeneratorPage extends StatefulWidget {
  const StoryGeneratorPage({super.key});

  @override
  State<StoryGeneratorPage> createState() => _StoryGeneratorPageState();
}

class _StoryGeneratorPageState extends State<StoryGeneratorPage> {
  final TextEditingController _promptController = TextEditingController();
  final List<String> emotions = ["Happy", "Sleepy", "Curious"];
  final List<String> settings = ["Space", "Forest", "Ocean"];
  String selectedEmotion = "Happy";
  String selectedSetting = "Forest";
  String? _generatedStory;
  bool _isLoading = false;

  final String openAIApiKey = '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'; // Replace with your API key

  ChildProfile? get activeChild => getDefaultChild();

  @override
  void initState() {
    super.initState();
    _prefillPrompt();
  }

  void _prefillPrompt() {
    final child = activeChild;
    final age = child?.age ?? 4;
    final name = child?.name ?? "a kid";

    final prompt = "Write a $selectedEmotion story for a $age-year-old named $name "
        "set in the $selectedSetting. Keep it short, fun, and engaging.";

    _promptController.text = prompt;
  }

  Future<void> _generateStory() async {
    final service = OpenAIService(apiKey: openAIApiKey);
    final inputPrompt = _promptController.text.trim();

    if (inputPrompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _generatedStory = null;
    });

    final story = await service.generateStory(inputPrompt);

    if (story != null && activeChild != null) {
      final storyBox = Hive.box<Story>('storiesBox');
      final newStory = Story(
        id: const Uuid().v4(),
        prompt: inputPrompt,
        generatedText: story,
        timestamp: DateTime.now(),
        childId: activeChild!.id,
      );
      await storyBox.put(newStory.id, newStory);

      setState(() {
        _generatedStory = story;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildChoiceChips({
    required List<String> options,
    required String selectedValue,
    required void Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(option),
          selected: selectedValue == option,
          onSelected: (_) {
            onSelected(option);
            _prefillPrompt();
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = activeChild;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child == null
            ? const Center(child: Text('Please create/select a child profile.'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi ${child.name}! Let's create a story.",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Pick an emotion:"),
            _buildChoiceChips(
              options: emotions,
              selectedValue: selectedEmotion,
              onSelected: (val) => setState(() => selectedEmotion = val),
            ),
            const SizedBox(height: 16),
            const Text("Pick a setting:"),
            _buildChoiceChips(
              options: settings,
              selectedValue: selectedSetting,
              onSelected: (val) => setState(() => selectedSetting = val),
            ),
            const SizedBox(height: 16),
            const Text("Prompt:"),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateStory,
              icon: const Icon(Icons.auto_stories),
              label: const Text("Generate Story"),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_generatedStory != null) ...[
              const Divider(height: 30),
              const Text("Generated Story:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_generatedStory!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
