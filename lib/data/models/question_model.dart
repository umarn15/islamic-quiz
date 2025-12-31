enum QuestionDifficulty { easy, medium, hard }

enum QuestionCategory {
  prayer,
  quran,
  prophets,
  pillars,
  manners,
  history,
  angels,
  beliefs,
  vocabulary,
  companions,
}

class QuestionModel {
  final String id;
  final String questionText;
  final QuestionDifficulty difficulty;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? audioUrl;
  final String language;
  final QuestionCategory category;

  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.difficulty,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.audioUrl,
    this.language = 'en',
    required this.category,
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      audioUrl: json['audioUrl'] as String?,
      language: json['language'] as String? ?? 'en',
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestionCategory.beliefs,
      ),
    );
  }

  /// Creates a QuestionModel from local JSON (local_questions.dart)
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
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      audioUrl: json['audioUrl'] as String?,
      language: json['language'] as String? ?? 'en',
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestionCategory.beliefs,
      ),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'audioUrl': audioUrl,
      'language': language,
      'category': category.name,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioUrl,
    String? language,
    QuestionCategory? category,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      difficulty: difficulty ?? this.difficulty,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      audioUrl: audioUrl ?? this.audioUrl,
      language: language ?? this.language,
      category: category ?? this.category,
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
