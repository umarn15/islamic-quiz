import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../local_questions.dart';

class QuestionService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'questions';
  static const String _configCollection = 'config';
  static const String _configDoc = 'app_settings';
  
  /// Cached value for useLocalDataOnly flag
  /// Defaults to true (local data) until fetched from Firestore
  static bool _useLocalDataOnly = true;
  static bool _configLoaded = false;

  QuestionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _questionsRef =>
      _firestore.collection(_collection);

  /// Fetches the useLocalDataOnly config from Firestore
  /// Call this once at app startup (e.g., in splash screen)
  /// Creates the config document if it doesn't exist
  Future<void> loadConfig() async {
    if (_configLoaded) return;
    
    try {
      final doc = await _firestore
          .collection(_configCollection)
          .doc(_configDoc)
          .get();
      
      if (doc.exists) {
        _useLocalDataOnly = doc.data()?['useLocalDataOnly'] ?? true;
      } else {
        // Create default config if it doesn't exist
        await _firestore
            .collection(_configCollection)
            .doc(_configDoc)
            .set({'useLocalDataOnly': true});
      }
      _configLoaded = true;
    } catch (e) {
      // On error, default to local data
      _useLocalDataOnly = true;
      _configLoaded = true;
    }
  }

  /// Returns current useLocalDataOnly value
  static bool get useLocalDataOnly => _useLocalDataOnly;

  /// Fetches all active questions
  /// Currently uses local data only (set _useLocalDataOnly = false to use Firestore)
  Future<List<QuestionModel>> getActiveQuestions() async {
    if (_useLocalDataOnly) {
      return _getLocalQuestions();
    }
    return _getActiveQuestionsFromFirestore();
  }

  /// Firestore implementation - kept for future use
  Future<List<QuestionModel>> _getActiveQuestionsFromFirestore() async {
    try {
      final snapshot = await _questionsRef
          .where('isActive', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return _getLocalQuestions();
      }
      
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      // Fallback to local questions if Firestore fails
      return _getLocalQuestions();
    }
  }

  /// Fetches questions by difficulty
  /// Currently uses local data only (set _useLocalDataOnly = false to use Firestore)
  Future<List<QuestionModel>> getQuestionsByDifficulty(
    QuestionDifficulty difficulty, {
    bool activeOnly = true,
  }) async {
    if (_useLocalDataOnly) {
      return _getLocalQuestions()
          .where((q) => q.difficulty == difficulty && (!activeOnly || q.isActive))
          .toList();
    }
    return _getQuestionsByDifficultyFromFirestore(difficulty, activeOnly: activeOnly);
  }

  /// Firestore implementation - kept for future use
  Future<List<QuestionModel>> _getQuestionsByDifficultyFromFirestore(
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
      
      if (snapshot.docs.isEmpty) {
        return _getLocalQuestions()
            .where((q) => q.difficulty == difficulty && (!activeOnly || q.isActive))
            .toList();
      }
      
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      return _getLocalQuestions()
          .where((q) => q.difficulty == difficulty && (!activeOnly || q.isActive))
          .toList();
    }
  }

  /// Fetches questions by category
  /// Currently uses local data only (set _useLocalDataOnly = false to use Firestore)
  Future<List<QuestionModel>> getQuestionsByCategory(
    QuestionCategory category, {
    bool activeOnly = true,
  }) async {
    if (_useLocalDataOnly) {
      return _getLocalQuestions()
          .where((q) => q.category == category && (!activeOnly || q.isActive))
          .toList();
    }
    return _getQuestionsByCategoryFromFirestore(category, activeOnly: activeOnly);
  }

  /// Firestore implementation - kept for future use
  Future<List<QuestionModel>> _getQuestionsByCategoryFromFirestore(
    QuestionCategory category, {
    bool activeOnly = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _questionsRef
          .where('category', isEqualTo: category.name);
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        return _getLocalQuestions()
            .where((q) => q.category == category && (!activeOnly || q.isActive))
            .toList();
      }
      
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      return _getLocalQuestions()
          .where((q) => q.category == category && (!activeOnly || q.isActive))
          .toList();
    }
  }

  /// Fetches questions by difficulty and category
  /// Currently uses local data only (set _useLocalDataOnly = false to use Firestore)
  Future<List<QuestionModel>> getQuestionsByDifficultyAndCategory(
    QuestionDifficulty difficulty,
    QuestionCategory category, {
    bool activeOnly = true,
  }) async {
    if (_useLocalDataOnly) {
      return _getLocalQuestions()
          .where((q) => 
              q.difficulty == difficulty && 
              q.category == category && 
              (!activeOnly || q.isActive))
          .toList();
    }
    return _getQuestionsByDifficultyAndCategoryFromFirestore(
      difficulty, category, activeOnly: activeOnly);
  }

  /// Firestore implementation - kept for future use
  Future<List<QuestionModel>> _getQuestionsByDifficultyAndCategoryFromFirestore(
    QuestionDifficulty difficulty,
    QuestionCategory category, {
    bool activeOnly = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _questionsRef
          .where('difficulty', isEqualTo: difficulty.name)
          .where('category', isEqualTo: category.name);
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        return _getLocalQuestions()
            .where((q) => 
                q.difficulty == difficulty && 
                q.category == category && 
                (!activeOnly || q.isActive))
            .toList();
      }
      
      return snapshot.docs
          .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      return _getLocalQuestions()
          .where((q) => 
              q.difficulty == difficulty && 
              q.category == category && 
              (!activeOnly || q.isActive))
          .toList();
    }
  }

  /// Fetches all questions (for admin panel)
  /// Currently uses local data only (set _useLocalDataOnly = false to use Firestore)
  Future<List<QuestionModel>> getAllQuestions() async {
    if (_useLocalDataOnly) {
      return _getAllLocalQuestions();
    }
    return _getAllQuestionsFromFirestore();
  }

  /// Firestore implementation - kept for future use
  Future<List<QuestionModel>> _getAllQuestionsFromFirestore() async {
    final snapshot = await _questionsRef.get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromJson(doc.data(), docId: doc.id))
        .toList();
  }

  /// Gets all local questions (including inactive)
  List<QuestionModel> _getAllLocalQuestions() {
    return initialQuestions
        .map((q) => QuestionModel.fromLocalJson(q))
        .toList();
  }

  /// Adds a new question
  /// Note: Only works with Firestore. In local mode, this is a no-op.
  Future<void> addQuestion(QuestionModel question) async {
    if (_useLocalDataOnly) {
      // In local mode, we can't add questions dynamically
      // This would require modifying the local_questions.dart file
      return;
    }
    await _questionsRef.doc(question.id).set(question.toJson());
  }

  /// Updates an existing question
  /// Note: Only works with Firestore. In local mode, this is a no-op.
  Future<void> updateQuestion(QuestionModel question) async {
    if (_useLocalDataOnly) {
      // In local mode, we can't update questions dynamically
      return;
    }
    await _questionsRef.doc(question.id).update(question.toJson());
  }

  /// Toggles question active status (for admin panel)
  /// Note: Only works with Firestore. In local mode, this is a no-op.
  Future<void> toggleQuestionStatus(String questionId, bool isActive) async {
    if (_useLocalDataOnly) {
      // In local mode, we can't toggle status dynamically
      return;
    }
    await _questionsRef.doc(questionId).update({'isActive': isActive});
  }

  /// Deletes a question
  /// Note: Only works with Firestore. In local mode, this is a no-op.
  Future<void> deleteQuestion(String questionId) async {
    if (_useLocalDataOnly) {
      // In local mode, we can't delete questions dynamically
      return;
    }
    await _questionsRef.doc(questionId).delete();
  }

  /// Seeds Firestore with initial questions
  /// Note: Only works with Firestore. In local mode, this is a no-op.
  Future<void> seedQuestions({bool overwrite = false}) async {
    if (_useLocalDataOnly) {
      // In local mode, questions are already seeded from local_questions.dart
      return;
    }
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

  /// Checks if questions exist
  /// In local mode, always returns true since local questions are always available
  Future<bool> hasQuestions() async {
    if (_useLocalDataOnly) {
      return initialQuestions.isNotEmpty;
    }
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
