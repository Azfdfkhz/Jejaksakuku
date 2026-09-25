import 'package:uuid/uuid.dart';

enum AttendanceStatus { hadir, izin, sakit, alpha }

class Attendance {
  final String id;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String notes;
  final DateTime createdAt;

  Attendance({
    String? id,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.notes = '',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Attendance copyWith({
    String? id,
    DateTime? date,
    AttendanceStatus? status,
    DateTime? checkIn,
    DateTime? checkOut,
    String? notes,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status.name,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      date: DateTime.parse(map['date']),
      status: AttendanceStatus.values.firstWhere((e) => e.name == map['status']),
      checkIn: map['checkIn'] != null ? DateTime.parse(map['checkIn']) : null,
      checkOut: map['checkOut'] != null ? DateTime.parse(map['checkOut']) : null,
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
