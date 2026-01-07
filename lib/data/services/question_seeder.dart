import 'package:shared_preferences/shared_preferences.dart';
import 'question_service.dart';

/// Utility class to seed Firestore with initial questions
class QuestionSeeder {
  static const String _seededKey = 'questions_seeded';
  final QuestionService _questionService;
  final SharedPreferences _prefs;

  QuestionSeeder({
    QuestionService? questionService,
    required SharedPreferences prefs,
  })  : _questionService = questionService ?? QuestionService(),
        _prefs = prefs;

  /// Check if questions have been seeded before
  bool get hasBeenSeeded => _prefs.getBool(_seededKey) ?? false;

  /// Seeds Firestore with initial questions if not already seeded
  /// Returns true if seeding was performed, false if already seeded
  Future<bool> seedIfNeeded() async {

    if (hasBeenSeeded) {
      return false;
    }

    // Skip seeding if using local data only
    if (QuestionService.useLocalDataOnly) {
      return false;
    }

    // Double-check by querying Firestore
    final hasQuestions = await _questionService.hasQuestions();
    if (hasQuestions) {
      await _markAsSeeded();
      return false;
    }

    // Seed the questions
    await _questionService.seedQuestions();
    await _markAsSeeded();
    return true;
  }

  /// Force seed questions (useful for admin/reset)
  Future<void> forceSeed({bool overwrite = true}) async {
    await _questionService.seedQuestions(overwrite: overwrite);
    await _markAsSeeded();
  }

  /// Reset seeded flag (for testing purposes)
  Future<void> resetSeededFlag() async {
    await _prefs.remove(_seededKey);
  }

  Future<void> _markAsSeeded() async {
    await _prefs.setBool(_seededKey, true);
  }
}
