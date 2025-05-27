// widgets/story_list.dart
import 'package:flutter/material.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // dummy count
      itemBuilder: (context, index) => ListTile(
        title: Text("Story ${index + 1}"),
        trailing: IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
      ),
    );
  }
}