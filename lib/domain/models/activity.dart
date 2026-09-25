import 'package:uuid/uuid.dart';
import 'package:jejak_saku/domain/models/task.dart';

class Activity {
  final String id;
  final String? taskId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final TaskCategory category;
  final String? projectId;
  final bool isCompleted;
  final DateTime createdAt;

  Activity({
    String? id,
    this.taskId,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.category = TaskCategory.pkl,
    this.projectId,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Activity copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    TaskCategory? category,
    String? projectId,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      projectId: projectId ?? this.projectId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category.name,
      'projectId': projectId,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.pkl,
      ),
      projectId: map['projectId'],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
