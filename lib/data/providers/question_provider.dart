import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';

/// Provider for QuestionService
final questionServiceProvider = Provider<QuestionService>((ref) {
  return QuestionService();
});

/// Provider for all active questions
final activeQuestionsProvider = FutureProvider<List<QuestionModel>>((ref) async {
  final service = ref.watch(questionServiceProvider);
  return service.getActiveQuestions();
});

/// Provider for questions by difficulty
final questionsByDifficultyProvider = FutureProvider.family<List<QuestionModel>, QuestionDifficulty>(
  (ref, difficulty) async {
    final service = ref.watch(questionServiceProvider);
    return service.getQuestionsByDifficulty(difficulty);
  },
);

/// Provider for all questions (admin panel)
final allQuestionsProvider = FutureProvider<List<QuestionModel>>((ref) async {
  final service = ref.watch(questionServiceProvider);
  return service.getAllQuestions();
});

/// Provider to check if Firestore has been seeded
final hasQuestionsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(questionServiceProvider);
  return service.hasQuestions();
});

/// State notifier for managing question operations (admin)
class QuestionNotifier extends StateNotifier<AsyncValue<List<QuestionModel>>> {
  final QuestionService _service;

  QuestionNotifier(this._service) : super(const AsyncValue.loading()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    state = const AsyncValue.loading();
    try {
      final questions = await _service.getAllQuestions();
      state = AsyncValue.data(questions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addQuestion(QuestionModel question) async {
    try {
      await _service.addQuestion(question);
      await loadQuestions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuestion(QuestionModel question) async {
    try {
      await _service.updateQuestion(question);
      await loadQuestions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleQuestionStatus(String questionId, bool isActive) async {
    try {
      await _service.toggleQuestionStatus(questionId, isActive);
      await loadQuestions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _service.deleteQuestion(questionId);
      await loadQuestions();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> seedQuestions({bool overwrite = false}) async {
    try {
      await _service.seedQuestions(overwrite: overwrite);
      await loadQuestions();
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for question management (admin panel)
final questionNotifierProvider = StateNotifierProvider<QuestionNotifier, AsyncValue<List<QuestionModel>>>((ref) {
  final service = ref.watch(questionServiceProvider);
  return QuestionNotifier(service);
});
