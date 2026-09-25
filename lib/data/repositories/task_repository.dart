import '../../domain/models/models.dart';

class TaskRepository {
  final List<Task> _tasks = [];

  Future<List<Task>> getTasks() async {
    return List.from(_tasks);
  }

  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    return _tasks.where((t) => t.category == category).toList();
  }

  Future<Task?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(updatedAt: DateTime.now());
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}
