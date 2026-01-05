import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamicquiz/core/localization/app_localizations.dart';
import 'package:islamicquiz/core/localization/locale_provider.dart';
import 'package:islamicquiz/core/theme_data.dart';
import 'package:islamicquiz/data/providers/shared_prefs_provider.dart';
import 'package:islamicquiz/firebase_options.dart';
import 'package:islamicquiz/ui/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(child: const MyApp(),
  overrides: [sharedPrefsProvider.overrideWithValue(prefs)],));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider);
    final currentTheme = themeNotifier.currentTheme;
    final locale = ref.watch(localeProvider);

    // Update system overlay style based on current theme
    SystemChrome.setSystemUIOverlayStyle(
      systemOverlayStyle(themeNotifier.isDarkMode),
    );

    return MaterialApp(
      title: 'Islamic Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: currentTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
