// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kiddyverse/models/child_profile.dart';
import 'package:kiddyverse/models/story.dart';
import 'package:kiddyverse/pages/splash_screen.dart';
import 'package:kiddyverse/pages/manage_profiles_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(ChildProfileAdapter());
  Hive.registerAdapter(StoryAdapter());

  await Hive.openBox<ChildProfile>('childrenBox');
  await Hive.openBox<String>('prefsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiddyVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/manage-profiles': (context) => const ManageProfilesPage(),
      },
    );
  }
}
