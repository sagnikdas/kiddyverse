import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kiddyverse/pages/create_edit_profile_page.dart';
import 'package:kiddyverse/pages/sign_in_page.dart';
import 'package:kiddyverse/pages/story_generator_page.dart';
import 'package:path_provider/path_provider.dart';
import 'models/child_profile.dart';
import 'models/story.dart';
import 'pages/splash_screen.dart';
import 'pages/manage_profiles_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/story_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(ChildProfileAdapter());
  Hive.registerAdapter(StoryAdapter());

  await Hive.openBox<ChildProfile>('childrenBox');
  await Hive.openBox<Story>('storiesBox');
  await Hive.openBox<String>('prefsBox');

  runApp(const KiddyVerseApp());
}

class KiddyVerseApp extends StatelessWidget {
  const KiddyVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KiddyVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
        fontFamily: 'ComicSans', // Optional: kid-friendly font
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/sign-in': (context) => const SignInPage(),
        '/manage-profiles': (context) => const ManageProfilesPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/story-generator': (context) => const StoryGeneratorPage(),
        '/stories': (context) => const StoryListPage(),
        '/create-profile': (context) => const CreateEditProfilePage(),
      },
    );
  }
}
