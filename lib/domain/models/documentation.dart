import 'package:uuid/uuid.dart';

class Documentation {
  final String id;
  final String activityId;
  final String imagePath;
  final String description;
  final DateTime date;
  final DateTime time;
  final List<String> tags;
  final DateTime createdAt;

  Documentation({
    String? id,
    required this.activityId,
    required this.imagePath,
    this.description = '',
    required this.date,
    required this.time,
    this.tags = const [],
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Documentation copyWith({
    String? id,
    String? activityId,
    String? imagePath,
    String? description,
    DateTime? date,
    DateTime? time,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Documentation(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'imagePath': imagePath,
      'description': description,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Documentation.fromMap(Map<String, dynamic> map) {
    return Documentation(
      id: map['id'],
      activityId: map['activityId'],
      imagePath: map['imagePath'],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      time: DateTime.parse(map['time']),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
