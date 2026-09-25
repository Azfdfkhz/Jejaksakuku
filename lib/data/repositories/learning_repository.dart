import '../../domain/models/models.dart';

class LearningRepository {
  final List<LearningGoal> _goals = [];
  final List<LearningSession> _sessions = [];
  final List<LearningNote> _notes = [];

  // Goals
  Future<List<LearningGoal>> getGoals() async {
    return List.from(_goals);
  }

  Future<void> addGoal(LearningGoal goal) async {
    _goals.add(goal);
  }

  Future<void> updateGoal(LearningGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    _sessions.removeWhere((s) => s.goalId == id);
    _notes.removeWhere((n) => n.goalId == id);
  }

  // Sessions
  Future<List<LearningSession>> getSessionsForGoal(String goalId) async {
    return _sessions.where((s) => s.goalId == goalId).toList();
  }

  Future<void> addSession(LearningSession session) async {
    _sessions.add(session);
  }

  Future<void> updateSession(LearningSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    }
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    _notes.removeWhere((n) => n.sessionId == id);
  }

  // Notes
  Future<List<LearningNote>> getNotesForSession(String sessionId) async {
    return _notes.where((n) => n.sessionId == sessionId).toList();
  }

  Future<List<LearningNote>> getNotesForGoal(String goalId) async {
    return _notes.where((n) => n.goalId == goalId).toList();
  }

  Future<void> addNote(LearningNote note) async {
    _notes.add(note);
  }

  Future<void> updateNote(LearningNote note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }
}
