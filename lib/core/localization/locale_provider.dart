import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamicquiz/data/providers/shared_prefs_provider.dart';
import 'package:islamicquiz/core/localization/question_localizations.dart';

const String _localeKey = 'app_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  static Locale _loadLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
    // Reinitialize question localizations when locale changes
    await QuestionLocalizations.init(locale);
    state = locale;
  }

  bool get isUrdu => state.languageCode == 'ur';
  bool get isEnglish => state.languageCode == 'en';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocaleNotifier(prefs);
});
