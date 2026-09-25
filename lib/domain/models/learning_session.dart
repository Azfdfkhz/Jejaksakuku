import 'package:uuid/uuid.dart';

class LearningSession {
  final String id;
  final String goalId;
  final String topic;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  LearningSession({
    String? id,
    required this.goalId,
    required this.topic,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.notes = '',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  LearningSession copyWith({
    String? id,
    String? goalId,
    String? topic,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return LearningSession(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      topic: topic ?? this.topic,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'topic': topic,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LearningSession.fromMap(Map<String, dynamic> map) {
    return LearningSession(
      id: map['id'],
      goalId: map['goalId'],
      topic: map['topic'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
