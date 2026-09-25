import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:jejak_saku/domain/models/models.dart';

/// Local JSON persistence service for Jejak Saku.
/// Saves and loads all user data so nothing is lost between sessions.
class LocalStorageService {
  static const String _fileName = 'jejak_saku_userdata.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<Map<String, dynamic>?> loadData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return null;
      }
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveData({
    required List<Task> todayTasks,
    required List<Task> unscheduledTasks,
    required List<Schedule> todaySchedules,
    required List<Activity> recentActivities,
    required List<Documentation> documentationList,
    required List<LearningGoal> learningGoals,
    required List<LearningNote> learningNotes,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final file = await _getFile();
      final data = {
        'todayTasks': todayTasks.map((t) => t.toMap()).toList(),
        'unscheduledTasks': unscheduledTasks.map((t) => t.toMap()).toList(),
        'todaySchedules': todaySchedules.map((s) => s.toMap()).toList(),
        'recentActivities': recentActivities.map((a) => a.toMap()).toList(),
        'documentationList': documentationList.map((d) => d.toMap()).toList(),
        'learningGoals': learningGoals.map((g) => g.toMap()).toList(),
        'learningNotes': learningNotes.map((n) => n.toMap()).toList(),
        'userProfile': userProfile,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  static Future<void> clearData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
