// lib/pages/story_list_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/story.dart';

class StoryListPage extends StatefulWidget {
  const StoryListPage({super.key});

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  late Box<Story> _storyBox;
  late Box<String> _prefsBox;
  String? _defaultChildId;

  @override
  void initState() {
    super.initState();
    _storyBox = Hive.box<Story>('storiesBox');
    _prefsBox = Hive.box<String>('prefsBox');
    _defaultChildId = _prefsBox.get('defaultChildId');
  }

  @override
  Widget build(BuildContext context) {
    final List<Story> stories = _storyBox.values
        .where((story) => story.childId == _defaultChildId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Stories"),
      ),
      body: stories.isEmpty
          ? const Center(child: Text("No stories found for this profile."))
          : ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Dismissible(
            key: Key(story.id),
            background: Container(color: Colors.red, child: const Icon(Icons.delete)),
            onDismissed: (_) {
              _storyBox.delete(story.id);
              setState(() {});
            },
            child: ListTile(
              title: Text(
                story.prompt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                story.timestamp.toString(),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: Icon(
                  story.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: story.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  _storyBox.put(
                    story.id,
                    story.copyWith(isFavorite: !story.isFavorite),
                  );
                  setState(() {});
                },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(story.prompt),
                    content: SingleChildScrollView(
                      child: Text(story.generatedText),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
