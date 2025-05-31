import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:kiddyverse/models/child_profile.dart';

class CreateEditProfilePage extends StatefulWidget {
  const CreateEditProfilePage({super.key});

  @override
  State<CreateEditProfilePage> createState() => _CreateEditProfilePageState();
}

class _CreateEditProfilePageState extends State<CreateEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedAvatar = "🐰";
  final List<String> _emojiOptions = ["🐰", "🐶", "🦄", "🐱", "🐵"];
  bool _saving = false;

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _saving = true);

    final newProfile = ChildProfile(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      avatar: _selectedAvatar,
    );

    final childrenBox = Hive.box<ChildProfile>('childrenBox');
    final prefsBox = Hive.box<String>('prefsBox');

    await childrenBox.put(newProfile.id, newProfile);
    await prefsBox.put('defaultChildId', newProfile.id);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Child Profile'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Child\'s Name'),
                validator: (value) => value!.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Child\'s Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final age = int.tryParse(value!);
                  if (age == null || age <= 0) return 'Enter valid age';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Pick an Avatar'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _emojiOptions.map((emoji) {
                  return ChoiceChip(
                    label: Text(emoji, style: const TextStyle(fontSize: 24)),
                    selected: _selectedAvatar == emoji,
                    onSelected: (_) => setState(() => _selectedAvatar = emoji),
                  );
                }).toList(),
              ),
              const Spacer(),
              _saving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Continue to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
