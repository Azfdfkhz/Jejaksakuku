import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String category;
  final String color;
  final DateTime createdAt;

  Project({
    String? id,
    required this.name,
    this.description = '',
    required this.category,
    required this.color,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? color,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      category: map['category'],
      color: map['color'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
