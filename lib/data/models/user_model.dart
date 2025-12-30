class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int points;
  final int level;
  final int quizzesCompleted;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.points = 0,
    this.level = 1,
    this.quizzesCompleted = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
      quizzesCompleted: map['quizzesCompleted'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'points': points,
      'level': level,
      'quizzesCompleted': quizzesCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? points,
    int? level,
    int? quizzesCompleted,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      points: points ?? this.points,
      level: level ?? this.level,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate level based on points (every 100 points = 1 level)
  static int calculateLevel(int points) {
    return (points ~/ 100) + 1;
  }
}
