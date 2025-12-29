import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../initial_questions.dart';

class QuestionService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'questions';

  QuestionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _questionsRef =>
      _firestore.collection(_collection);

  /// Fetches all active questions from Firestore
  Future<List<QuestionModel>> getActiveQuestions() async {
    try {
      final snapshot = await _questionsRef
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      // Fallback to local questions if Firestore fails
      return _getLocalQuestions();
    }
  }

  /// Fetches questions by difficulty
  Future<List<QuestionModel>> getQuestionsByDifficulty(
    QuestionDifficulty difficulty, {
    bool activeOnly = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _questionsRef
          .where('difficulty', isEqualTo: difficulty.name);
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      return _getLocalQuestions()
          .where((q) => q.difficulty == difficulty && (!activeOnly || q.isActive))
          .toList();
    }
  }

  /// Fetches all questions (for admin panel)
  Future<List<QuestionModel>> getAllQuestions() async {
    final snapshot = await _questionsRef.get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
        .toList();
  }

  /// Adds a new question
  Future<void> addQuestion(QuestionModel question) async {
    await _questionsRef.doc(question.id).set(question.toJson());
  }

  /// Updates an existing question
  Future<void> updateQuestion(QuestionModel question) async {
    await _questionsRef.doc(question.id).update(question.toJson());
  }

  /// Toggles question active status (for admin panel)
  Future<void> toggleQuestionStatus(String questionId, bool isActive) async {
    await _questionsRef.doc(questionId).update({'isActive': isActive});
  }

  /// Deletes a question
  Future<void> deleteQuestion(String questionId) async {
    await _questionsRef.doc(questionId).delete();
  }

  /// Seeds Firestore with initial questions
  Future<void> seedQuestions({bool overwrite = false}) async {
    final batch = _firestore.batch();
    
    for (final questionData in initialQuestions) {
      final question = QuestionModel.fromLocalJson(questionData);
      final docRef = _questionsRef.doc(question.id);
      
      if (overwrite) {
        batch.set(docRef, question.toJson());
      } else {
        batch.set(docRef, question.toJson(), SetOptions(merge: true));
      }
    }
    
    await batch.commit();
  }

  /// Checks if questions exist in Firestore
  Future<bool> hasQuestions() async {
    final snapshot = await _questionsRef.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  /// Gets local questions as fallback
  List<QuestionModel> _getLocalQuestions() {
    return initialQuestions
        .map((q) => QuestionModel.fromLocalJson(q))
        .where((q) => q.isActive)
        .toList();
  }

  /// Gets local questions directly (for offline mode)
  static List<QuestionModel> getLocalQuestionsStatic() {
    return initialQuestions
        .map((q) => QuestionModel.fromLocalJson(q))
        .toList();
  }
}
