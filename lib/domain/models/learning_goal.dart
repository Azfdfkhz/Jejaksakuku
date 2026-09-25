import 'package:uuid/uuid.dart';

class LearningGoal {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final double progress;
  final DateTime createdAt;

  LearningGoal({
    String? id,
    required this.title,
    this.description = '',
    required this.targetDate,
    this.progress = 0.0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  LearningGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    double? progress,
    DateTime? createdAt,
  }) {
    return LearningGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetDate': targetDate.toIso8601String(),
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LearningGoal.fromMap(Map<String, dynamic> map) {
    return LearningGoal(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      targetDate: DateTime.parse(map['targetDate']),
      progress: map['progress']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
