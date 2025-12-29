import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/providers/shared_prefs_provider.dart';

const Color primaryGreen = Color(0xFF4CAF50); // Fresh green
const Color secondaryTeal = Color(0xFF00BCD4); // Bright teal
const Color accentGold = Color(0xFFFFB300); // Warm gold
const Color backgroundCream = Color(0xFFFFF8E1); // Soft cream
const Color cardWhite = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2C3E50);
const Color textLight = Color(0xFF7F8C8D);
const Color successGreen = Color(0xFF66BB6A);
const Color errorRed = Color(0xFFEF5350);
const Color starYellow = Color(0xFFFFC107);
const darkBackgroundColor = Color(0xFF121212);

SystemUiOverlayStyle systemOverlayStyle(bool darkMode){
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: darkMode? Brightness.light : Brightness.dark,
    statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: darkMode? darkBackgroundColor : Color(0xFFFFF8E1),
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
      primary: primaryGreen,
      secondary: secondaryTeal,
      tertiary: accentGold,
      surface: const Color(0xFF1E1E1E),
      error: errorRed,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
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
        color: Color(0xFFE0E0E0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFB0B0B0),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    dividerColor: Colors.grey.shade700,

    // Icon Theme
    iconTheme: const IconThemeData(
      color: primaryGreen,
      size: 24,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryTeal,
      tertiary: accentGold,
      surface: cardWhite,
      error: errorRed,
    ),
    scaffoldBackgroundColor: backgroundCream,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    dividerColor: Colors.grey.shade400,

    // Icon Theme
    iconTheme: const IconThemeData(
      color: primaryGreen,
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