import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/providers/shared_prefs_provider.dart';

// Playful purple theme for kids
const Color primaryPurple = Color(0xFF6B4CE6); // Vibrant purple
const Color secondaryPurple = Color(0xFF8B6EF7); // Light purple
const Color accentPink = Color(0xFFFF6B9D); // Fun pink
const Color backgroundCream = Color(0xFFF5F7FF); // Soft lavender
const Color cardWhite = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3748); // Soft dark
const Color textLight = Color(0xFF718096); // Soft gray
const Color successGreen = Color(0xFF4CAF50); // Bright green
const Color errorRed = Color(0xFFF44336); // Bright red
const Color starYellow = Color(0xFFFFC107); // Bright yellow
const Color darkBackgroundColor = Color(0xFF1A1F2E); // Deep purple-dark

SystemUiOverlayStyle systemOverlayStyle(bool darkMode){
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: darkMode? Brightness.light : Brightness.dark,
    statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: darkMode? darkBackgroundColor : backgroundCream,
    systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
  );
}

final themeProvider = ChangeNotifierProvider<ThemeProvider>(
        (ref) => ThemeProvider(ref.watch(sharedPrefsProvider)));

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  bool isDarkMode = false;

  ThemeProvider(this.prefs) {
    loadFromPrefs();
  }

  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  toggleTheme() async {
    isDarkMode = !isDarkMode;
    await saveToPrefs();
    notifyListeners();
  }

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF8B6EF7), // Bright purple
      secondary: const Color(0xFFAB8EFF), // Light purple
      tertiary: const Color(0xFFFF6B9D), // Fun pink
      surface: const Color(0xFF252B3B),
      error: const Color(0xFFF87171), // Softer red for dark
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF252B3B),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE2E8F0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF94A3B8),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: const Color(0xFF252B3B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Color(0xFF3D4458), width: 1.5),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B6EF7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    dividerColor: const Color(0xFF3D4458),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Color(0xFF8B6EF7),
      size: 24,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryPurple,
      secondary: secondaryPurple,
      tertiary: accentPink,
      surface: cardWhite,
      error: errorRed,
    ),
    scaffoldBackgroundColor: backgroundCream,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF2D3748),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFF2D3748),
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textLight,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    dividerColor: const Color(0xFFE5E7EB),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: primaryPurple,
      size: 24,
    ),
  );

  loadFromPrefs() {
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveToPrefs() async {
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}