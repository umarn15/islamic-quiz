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

/// Holds inline translations for a question in a specific language
/// Used for custom questions added via admin panel
class QuestionTranslation {
  final String questionText;
  final List<String> options;
  final String? explanation;

  const QuestionTranslation({
    required this.questionText,
    required this.options,
    this.explanation,
  });

  factory QuestionTranslation.fromJson(Map<String, dynamic> json) {
    return QuestionTranslation(
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

/// Language-agnostic question model using localization keys
/// All text content is resolved via localization files at runtime
/// For custom questions, inline translations are stored in Firestore
class QuestionModel {
  final String id;
  final String questionKey;
  final QuestionDifficulty difficulty;
  final List<String> optionsKeys;
  final int correctOptionIndex;
  final String? explanationKey;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? audioKey; // Resolved as: audio/{locale}/{audioKey}.mp3
  final QuestionCategory category;
  
  /// Inline translations for custom questions added via admin panel
  /// Key is language code (e.g., 'en', 'ur')
  final Map<String, QuestionTranslation>? translations;

  const QuestionModel({
    required this.id,
    required this.questionKey,
    required this.difficulty,
    required this.optionsKeys,
    required this.correctOptionIndex,
    this.explanationKey,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.audioKey,
    required this.category,
    this.translations,
  });

  /// Check if this question has inline translations (custom question from admin)
  bool get hasInlineTranslations => translations != null && translations!.isNotEmpty;

  /// Get translation for a specific language, returns null if not found
  QuestionTranslation? getTranslation(String langCode) => translations?[langCode];

  /// Creates a QuestionModel from Firestore document
  factory QuestionModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    // Parse inline translations if present
    Map<String, QuestionTranslation>? translations;
    if (json['translations'] != null) {
      final translationsJson = json['translations'] as Map<String, dynamic>;
      translations = translationsJson.map(
        (key, value) => MapEntry(
          key,
          QuestionTranslation.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return QuestionModel(
      id: docId ?? json['id'] as String,
      questionKey: json['questionKey'] as String,
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuestionDifficulty.easy,
      ),
      optionsKeys: List<String>.from(json['optionsKeys'] as List),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanationKey: json['explanationKey'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      audioKey: json['audioKey'] as String?,
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestionCategory.beliefs,
      ),
      translations: translations,
    );
  }

  /// Creates a QuestionModel from local seed data
  factory QuestionModel.fromLocalJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      questionKey: json['questionKey'] as String,
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuestionDifficulty.easy,
      ),
      optionsKeys: List<String>.from(json['optionsKeys'] as List),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanationKey: json['explanationKey'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      audioKey: json['audioKey'] as String?,
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
      'questionKey': questionKey,
      'difficulty': difficulty.name,
      'optionsKeys': optionsKeys,
      'correctOptionIndex': correctOptionIndex,
      'explanationKey': explanationKey,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'audioKey': audioKey,
      'category': category.name,
      if (translations != null)
        'translations': translations!.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
    };
  }

  /// Creates a copy with modified fields
  QuestionModel copyWith({
    String? id,
    String? questionKey,
    QuestionDifficulty? difficulty,
    List<String>? optionsKeys,
    int? correctOptionIndex,
    String? explanationKey,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioKey,
    QuestionCategory? category,
    Map<String, QuestionTranslation>? translations,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionKey: questionKey ?? this.questionKey,
      difficulty: difficulty ?? this.difficulty,
      optionsKeys: optionsKeys ?? this.optionsKeys,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanationKey: explanationKey ?? this.explanationKey,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      audioKey: audioKey ?? this.audioKey,
      category: category ?? this.category,
      translations: translations ?? this.translations,
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
