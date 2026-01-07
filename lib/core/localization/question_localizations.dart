import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:islamicquiz/data/models/question_model.dart';

/// Localization loader for question content
/// Loads JSON files from assets/l10n/{locale}.json
/// Also supports inline translations for custom questions
class QuestionLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;
  static QuestionLocalizations? _instance;
  static Locale? _currentLocale;

  QuestionLocalizations(this.locale);

  /// Get the current instance
  static QuestionLocalizations? get instance => _instance;

  /// Load localization strings from JSON file
  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/l10n/${locale.languageCode}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Fallback to English if locale file not found
      if (locale.languageCode != 'en') {
        try {
          final jsonString = await rootBundle.loadString('assets/l10n/en.json');
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
          return true;
        } catch (_) {
          _localizedStrings = {};
          return false;
        }
      }
      _localizedStrings = {};
      return false;
    }
  }

  /// Translate a key to localized string
  String t(String key) {
    return _localizedStrings[key] ?? key;
  }

  /// Check if a key exists
  bool hasKey(String key) {
    return _localizedStrings.containsKey(key);
  }

  /// Get audio path for a given audio key and locale
  String getAudioPath(String audioKey) {
    return 'audio/${locale.languageCode}/$audioKey.mp3';
  }

  /// Initialize or update the singleton instance
  static Future<QuestionLocalizations> init(Locale locale) async {
    if (_instance == null || _currentLocale != locale) {
      _instance = QuestionLocalizations(locale);
      await _instance!.load();
      _currentLocale = locale;
    }
    return _instance!;
  }

  /// Get localized question text
  /// First checks inline translations (for custom questions), then falls back to JSON file
  String getQuestionText(String questionKey, {QuestionModel? question}) {
    // Check for inline translations first (custom questions from admin)
    if (question != null && question.hasInlineTranslations) {
      final translation = question.getTranslation(locale.languageCode);
      if (translation != null) {
        return translation.questionText;
      }
      // Fallback to English inline translation
      final enTranslation = question.getTranslation('en');
      if (enTranslation != null) {
        return enTranslation.questionText;
      }
    }
    // Fall back to JSON file
    return t(questionKey);
  }

  /// Get localized options
  /// First checks inline translations, then falls back to JSON file
  List<String> getOptions(List<String> optionsKeys, {QuestionModel? question}) {
    // Check for inline translations first (custom questions from admin)
    if (question != null && question.hasInlineTranslations) {
      final translation = question.getTranslation(locale.languageCode);
      if (translation != null) {
        return translation.options;
      }
      // Fallback to English inline translation
      final enTranslation = question.getTranslation('en');
      if (enTranslation != null) {
        return enTranslation.options;
      }
    }
    // Fall back to JSON file
    return optionsKeys.map((key) => t(key)).toList();
  }

  /// Get localized explanation
  /// First checks inline translations, then falls back to JSON file
  String? getExplanation(String? explanationKey, {QuestionModel? question}) {
    if (explanationKey == null && (question == null || !question.hasInlineTranslations)) {
      return null;
    }
    
    // Check for inline translations first (custom questions from admin)
    if (question != null && question.hasInlineTranslations) {
      final translation = question.getTranslation(locale.languageCode);
      if (translation != null && translation.explanation != null) {
        return translation.explanation;
      }
      // Fallback to English inline translation
      final enTranslation = question.getTranslation('en');
      if (enTranslation != null && enTranslation.explanation != null) {
        return enTranslation.explanation;
      }
    }
    // Fall back to JSON file
    if (explanationKey != null) {
      return t(explanationKey);
    }
    return null;
  }

  /// Get display text for admin panel (uses English as default for display)
  String getDisplayText(String key, {QuestionModel? question}) {
    if (question != null && question.hasInlineTranslations) {
      final enTranslation = question.getTranslation('en');
      if (enTranslation != null) {
        return enTranslation.questionText;
      }
    }
    return t(key);
  }
}

/// Extension for easy access in widgets
extension QuestionLocalizationsExtension on BuildContext {
  QuestionLocalizations get questionL10n => QuestionLocalizations.instance!;
}
