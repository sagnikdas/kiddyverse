// home_page.dart
import 'package:flutter/material.dart';
import 'package:kiddyverse/widgets/story_generator.dart';
import 'package:kiddyverse/widgets/story_list.dart';
import 'package:kiddyverse/widgets/narration_recorder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const StoryGenerator(),
    const StoryList(),
    const NarrationRecorder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KiddyVerse"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Generate'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Stories'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Narration'),
        ],
      ),
    );
  }
}