import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:islamicquiz/core/theme_data.dart';
import 'package:islamicquiz/firebase_options.dart';
import 'package:islamicquiz/ui/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider).currentTheme;

    return MaterialApp(
      title: 'Islamic Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: currentTheme,
      home: const SplashScreen(),
    );
  }
}
