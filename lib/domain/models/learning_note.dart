import 'package:uuid/uuid.dart';

class LearningNote {
  final String id;
  final String? sessionId;
  final String? goalId;
  final String content;
  final DateTime createdAt;

  LearningNote({
    String? id,
    this.sessionId,
    this.goalId,
    required this.content,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  LearningNote copyWith({
    String? id,
    String? sessionId,
    String? goalId,
    String? content,
    DateTime? createdAt,
  }) {
    return LearningNote(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      goalId: goalId ?? this.goalId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'goalId': goalId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LearningNote.fromMap(Map<String, dynamic> map) {
    return LearningNote(
      id: map['id'],
      sessionId: map['sessionId'],
      goalId: map['goalId'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
