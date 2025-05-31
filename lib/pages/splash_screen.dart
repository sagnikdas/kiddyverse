import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:kiddyverse/models/child_profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _handleRouting);
  }

  Future<void> _handleRouting() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/sign-in');
      return;
    }

    final childrenBox = Hive.box<ChildProfile>('childrenBox');
    final prefsBox = Hive.box<String>('prefsBox');

    if (childrenBox.isEmpty) {
      Navigator.pushReplacementNamed(context, '/create-profile');
    } else {
      // If default child is not set, set the first one
      prefsBox.put('defaultChildId', prefsBox.get('defaultChildId') ?? childrenBox.values.first.id);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 120), // Placeholder logo
            const SizedBox(height: 20),
            const Text(
              'KiddyVerse',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
