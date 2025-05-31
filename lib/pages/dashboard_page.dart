import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kiddyverse/models/child_profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ChildProfile? _defaultChild;

  @override
  void initState() {
    super.initState();
    _loadDefaultChild();
  }

  void _loadDefaultChild() {
    final prefsBox = Hive.box<String>('prefsBox');
    final childrenBox = Hive.box<ChildProfile>('childrenBox');

    final defaultId = prefsBox.get('defaultChildId');
    if (defaultId != null) {
      _defaultChild = childrenBox.get(defaultId);
    }
    setState(() {});
  }

  void _goToStoryGenerator() {
    Navigator.pushNamed(context, '/story-generator');
  }

  void _goToManageProfiles() async {
    await Navigator.pushNamed(context, '/manage-profiles');
    _loadDefaultChild(); // Refresh in case default changed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KiddyVerse Dashboard'),
        backgroundColor: Colors.orangeAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orangeAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome, Parent!', style: TextStyle(fontSize: 20, color: Colors.white)),
                  if (_defaultChild != null)
                    Text('👦 ${_defaultChild!.name}, Age: ${_defaultChild!.age}',
                        style: const TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manage Profiles'),
              onTap: () {
                Navigator.pop(context);
                _goToManageProfiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                // TODO: Sign out logic
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_defaultChild != null)
              Text('👋 Hello ${_defaultChild!.name}!',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_stories),
              label: const Text('Generate a Story'),
              onPressed: _goToStoryGenerator,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
