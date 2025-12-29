enum QuestionDifficulty { easy, medium, hard }

class QuestionModel {
  final String id;
  final String questionText;
  final QuestionDifficulty difficulty;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final bool isActive;

  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.difficulty,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.isActive = true,
  });

  /// Creates a QuestionModel from Firestore document
  factory QuestionModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return QuestionModel(
      id: docId ?? json['id'] as String,
      questionText: json['questionText'] as String,
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuestionDifficulty.easy,
      ),
      options: List<String>.from(json['options'] as List),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanation: json['explanation'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Creates a QuestionModel from local JSON (initial_questions.dart)
  factory QuestionModel.fromLocalJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuestionDifficulty.easy,
      ),
      options: List<String>.from(json['options'] as List),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanation: json['explanation'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'difficulty': difficulty.name,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'isActive': isActive,
    };
  }

  /// Creates a copy with modified fields
  QuestionModel copyWith({
    String? id,
    String? questionText,
    QuestionDifficulty? difficulty,
    List<String>? options,
    int? correctOptionIndex,
    String? explanation,
    bool? isActive,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      difficulty: difficulty ?? this.difficulty,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
