import 'package:uuid/uuid.dart';

enum TaskStatus { unscheduled, scheduled, inProgress, completed, cancelled }
enum TaskCategory { pkl, learning, personal }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskStatus status;
  final String? projectId;
  final int priority;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.category,
    this.status = TaskStatus.unscheduled,
    this.projectId,
    this.priority = 0,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskStatus? status,
    String? projectId,
    int? priority,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'projectId': projectId,
      'priority': priority,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      category: TaskCategory.values.firstWhere((e) => e.name == map['category']),
      status: TaskStatus.values.firstWhere((e) => e.name == map['status']),
      projectId: map['projectId'],
      priority: map['priority']?.toInt() ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
