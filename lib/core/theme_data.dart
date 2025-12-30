import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/providers/shared_prefs_provider.dart';

const Color primaryGreen = Color(0xFF1B5E20); // Deep forest green
const Color secondaryTeal = Color(0xFF26A69A); // Elegant teal
const Color accentGold = Color(0xFFD4AF37); // Rich Islamic gold
const Color backgroundCream = Color(0xFFF5F5F5); // Clean light gray
const Color cardWhite = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF1A1A2E); // Deep navy-black
const Color textLight = Color(0xFF6B7280); // Soft gray
const Color successGreen = Color(0xFF10B981); // Modern emerald
const Color errorRed = Color(0xFFDC2626); // Clean red
const Color starYellow = Color(0xFFF59E0B); // Amber
const Color darkBackgroundColor = Color(0xFF0F172A); // Deep slate

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
      primary: const Color(0xFF4ADE80), // Bright emerald green
      secondary: const Color(0xFF5EEAD4), // Bright teal
      tertiary: const Color(0xFFFCD34D), // Bright gold
      surface: const Color(0xFF1E293B),
      error: const Color(0xFFF87171), // Softer red for dark
      onPrimary: const Color(0xFF0F172A),
      onSecondary: const Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: darkBackgroundColor,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
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
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFF334155), width: 1),
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
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    dividerColor: const Color(0xFF334155),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Color(0xFF26A69A),
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
      backgroundColor: Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFE5E7EB), width: 1),
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
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    dividerColor: const Color(0xFFE5E7EB),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Color(0xFF1B5E20),
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