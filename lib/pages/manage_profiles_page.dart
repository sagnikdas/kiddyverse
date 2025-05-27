// lib/pages/manage_profiles_page.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kiddyverse/models/child_profile.dart';
import 'package:uuid/uuid.dart';

class ManageProfilesPage extends StatefulWidget {
  const ManageProfilesPage({super.key});

  @override
  State<ManageProfilesPage> createState() => _ManageProfilesPageState();
}

class _ManageProfilesPageState extends State<ManageProfilesPage> {
  late Box<ChildProfile> _childBox;
  late Box<String> _prefsBox;
  String? _defaultChildId;

  final List<String> emojiOptions = ["🐰", "🐶", "🦄", "🐱", "🐵"];

  @override
  void initState() {
    super.initState();
    _childBox = Hive.box<ChildProfile>('childrenBox');
    _prefsBox = Hive.box<String>('prefsBox');
    _defaultChildId = _prefsBox.get('defaultChildId');
  }

  void _showProfileDialog({ChildProfile? profile}) {
    final TextEditingController nameController =
    TextEditingController(text: profile?.name ?? '');
    final TextEditingController ageController =
    TextEditingController(text: profile?.age.toString() ?? '');
    String selectedEmoji = profile?.avatar ?? emojiOptions.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profile == null ? 'Add Profile' : 'Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: emojiOptions.map((emoji) {
                return ChoiceChip(
                  label: Text(emoji, style: const TextStyle(fontSize: 20)),
                  selected: selectedEmoji == emoji,
                  onSelected: (_) => setState(() => selectedEmoji = emoji),
                );
              }).toList(),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final age = int.tryParse(ageController.text.trim()) ?? 0;
              if (name.isNotEmpty && age > 0) {
                if (profile == null) {
                  final newProfile = ChildProfile(
                    id: const Uuid().v4(),
                    name: name,
                    age: age,
                    avatar: selectedEmoji,
                  );
                  _childBox.put(newProfile.id, newProfile);
                } else {
                  final updated = ChildProfile(
                    id: profile.id,
                    name: name,
                    age: age,
                    avatar: selectedEmoji,
                  );
                  _childBox.put(profile.id, updated);
                }
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteProfile(String id) {
    if (_defaultChildId == id) {
      _prefsBox.delete('defaultChildId');
      _defaultChildId = null;
    }
    _childBox.delete(id);
    setState(() {});
  }

  void _setDefaultProfile(String id) {
    _prefsBox.put('defaultChildId', id);
    setState(() {
      _defaultChildId = id;
    });
  }

  static String? getDefaultChildId() {
    final prefsBox = Hive.box<String>('prefsBox');
    return prefsBox.get('defaultChildId');
  }

  @override
  Widget build(BuildContext context) {
    final children = _childBox.values.toList();
    final canAddMore = children.length < 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Child Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: canAddMore ? () => _showProfileDialog() : null,
          )
        ],
      ),
      body: children.isEmpty
          ? const Center(child: Text("No profiles yet. Tap + to add one."))
          : ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final isDefault = _defaultChildId == child.id;

          return ListTile(
            leading: Text(child.avatar, style: const TextStyle(fontSize: 24)),
            title: Text(child.name),
            subtitle: Text('Age: ${child.age}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDefault)
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    tooltip: "Set as default",
                    onPressed: () => _setDefaultProfile(child.id),
                  ),
                if (isDefault)
                  const Icon(Icons.star, color: Colors.orange),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showProfileDialog(profile: child),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProfile(child.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}