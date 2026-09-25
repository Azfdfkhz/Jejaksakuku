import 'package:flutter/foundation.dart';
import 'package:jejak_saku/domain/models/models.dart';
import 'package:jejak_saku/data/services/local_storage_service.dart';

enum PlannerViewMode { hari, minggu, bulan }

/// Central state and ViewModel for Jejak Saku.
/// Manages real tasks, schedules, activities, documentation, learning goals, notes, and local persistence.
class OverviewViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────

  List<Task> _todayTasks = [];
  List<Task> get todayTasks => List.unmodifiable(_todayTasks);

  List<Task> _unscheduledTasks = [];
  List<Task> get unscheduledTasks => List.unmodifiable(_unscheduledTasks);

  List<Schedule> _todaySchedules = [];
  List<Schedule> get todaySchedules => List.unmodifiable(_todaySchedules);

  List<Activity> _recentActivities = [];
  List<Activity> get recentActivities => List.unmodifiable(_recentActivities);

  List<Schedule> _upcomingSchedules = [];
  List<Schedule> get upcomingSchedules => List.unmodifiable(_upcomingSchedules);

  List<Documentation> _documentationList = [];
  List<Documentation> get documentationList => List.unmodifiable(_documentationList);

  List<LearningGoal> _learningGoals = [];
  List<LearningGoal> get learningGoals => List.unmodifiable(_learningGoals);

  List<LearningNote> _learningNotes = [];
  List<LearningNote> get learningNotes => List.unmodifiable(_learningNotes);

  PlannerViewMode _plannerViewMode = PlannerViewMode.hari;
  PlannerViewMode get plannerViewMode => _plannerViewMode;

  static DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _selectedDate = _todayDateOnly();
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadError;
  String? get loadError => _loadError;

  // ── User Profile ───────────────────────────────────────

  String _userName = '';
  String get userName => _userName;

  String _userRole = '';
  String get userRole => _userRole;

  String _userCompany = '';
  String get userCompany => _userCompany;

  String _userMentor = '';
  String get userMentor => _userMentor;

  /// Apakah user sudah mengisi identitas asli mereka sendiri.
  bool get hasProfile => _userName.trim().isNotEmpty;

  String get userStatus => 'Online';
  String get greetingName => _userName.trim().isEmpty ? 'Pengguna' : _userName.split(' ').first;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get greetingEmoji => '👋';

  DateTime get today => _selectedDate;

  int get totalTasks => _todayTasks.length;
  int get completedTasks =>
      _todayTasks.where((t) => t.status == TaskStatus.completed).length;

  double get progressPercent =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  // PKL schedule info
  String get pklSchedule => '08:00 - 16:00';
  bool get pklIsActive => true;

  double get pklProgress {
    final pklTasks =
        _todayTasks.where((t) => t.category == TaskCategory.pkl).toList();
    if (pklTasks.isEmpty) return 1.0;
    final completed =
        pklTasks.where((t) => t.status == TaskStatus.completed).length;
    return completed / pklTasks.length;
  }

  Schedule? get currentLearningSession {
    try {
      return _todaySchedules.firstWhere(
        (s) {
          final task = getTaskById(s.taskId);
          return task?.category == TaskCategory.learning;
        },
      );
    } catch (_) {
      return null;
    }
  }

  // ── Motivational Quotes ────────────────────────────────

  static const List<String> _quotes = [
    'Disiplin bukan tentang melakukan semua hal, tetapi tentang melakukan hal yang penting, secara konsisten.',
    'Langkah kecil hari ini, jadi cerita besar nanti.',
    'Setiap dokumentasi yang kamu buat adalah bukti perjalananmu.',
    'Konsistensi mengalahkan motivasi.',
    'Hari ini adalah kesempatan untuk menjadi lebih baik dari kemarin.',
  ];

  String get dailyQuote => _quotes[0];

  // ── Learning Progress Map ──────────────────────────────

  /// Progress belajar nyata dari [_learningGoals]. Mengembalikan map kosong
  /// jika belum ada goal — UI wajib menampilkan empty state, bukan angka
  /// contoh (lihat jejaksaku.md #1: no hardcoded statistics).
  Map<String, double> get learningProgress {
    if (_learningGoals.isEmpty) {
      return {};
    }
    final map = <String, double>{};
    for (final g in _learningGoals) {
      final key = g.title.length > 10 ? g.title.substring(0, 10) : g.title;
      map[key] = g.progress;
    }
    return map;
  }

  // ── Persistence Helper ─────────────────────────────────

  void _persist() {
    LocalStorageService.saveData(
      todayTasks: _todayTasks,
      unscheduledTasks: _unscheduledTasks,
      todaySchedules: _todaySchedules,
      recentActivities: _recentActivities,
      documentationList: _documentationList,
      learningGoals: _learningGoals,
      learningNotes: _learningNotes,
      userProfile: {
        'userName': _userName,
        'userRole': _userRole,
        'userCompany': _userCompany,
        'userMentor': _userMentor,
      },
    );
  }

  Map<String, dynamic> exportAllDataAsJson() {
    return {
      'todayTasks': _todayTasks.map((t) => t.toMap()).toList(),
      'unscheduledTasks': _unscheduledTasks.map((t) => t.toMap()).toList(),
      'todaySchedules': _todaySchedules.map((s) => s.toMap()).toList(),
      'recentActivities': _recentActivities.map((a) => a.toMap()).toList(),
      'documentationList': _documentationList.map((d) => d.toMap()).toList(),
      'learningGoals': _learningGoals.map((g) => g.toMap()).toList(),
      'learningNotes': _learningNotes.map((n) => n.toMap()).toList(),
      'userProfile': {
        'userName': _userName,
        'userRole': _userRole,
        'userCompany': _userCompany,
        'userMentor': _userMentor,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // ── Profile Updates ────────────────────────────────────

  void updateUserProfile({
    required String name,
    required String role,
    required String company,
    required String mentor,
  }) {
    _userName = name.trim();
    _userRole = role.trim();
    _userCompany = company.trim();
    _userMentor = mentor.trim();
    _persist();
    notifyListeners();
  }

  // ── Clear / Reset Data ─────────────────────────────────

  void clearAllData() {
    _todayTasks.clear();
    _unscheduledTasks.clear();
    _todaySchedules.clear();
    _recentActivities.clear();
    _upcomingSchedules.clear();
    _documentationList.clear();
    _learningGoals.clear();
    _learningNotes.clear();
    _persist();
    notifyListeners();
  }



  // ── View Mode Setter ───────────────────────────────────

  void setPlannerViewMode(PlannerViewMode mode) {
    _plannerViewMode = mode;
    notifyListeners();
  }

  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void goToToday() {
    _selectedDate = _todayDateOnly();
    notifyListeners();
  }

  // ── Task Management Actions ────────────────────────────

  void scheduleUnscheduledTask(Task task, DateTime startTime, DateTime endTime) {
    _unscheduledTasks.removeWhere((t) => t.id == task.id);
    final scheduledTask = task.copyWith(
      status: TaskStatus.scheduled,
      updatedAt: DateTime.now(),
    );
    _todayTasks.add(scheduledTask);

    final newSchedule = Schedule(
      taskId: scheduledTask.id,
      date: _selectedDate,
      startTime: startTime,
      endTime: endTime,
    );
    _todaySchedules.add(newSchedule);
    _todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    _persist();
    notifyListeners();
  }

  void addTask(Task task, {DateTime? startTime, DateTime? endTime}) {
    if (startTime != null && endTime != null) {
      final scheduledTask = task.copyWith(status: TaskStatus.scheduled);
      _todayTasks.add(scheduledTask);
      final schedule = Schedule(
        taskId: scheduledTask.id,
        date: _selectedDate,
        startTime: startTime,
        endTime: endTime,
      );
      _todaySchedules.add(schedule);
      _todaySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    } else {
      _unscheduledTasks.add(task);
    }
    _persist();
    notifyListeners();
  }

  void editTask(Task updated) {
    final idx1 = _todayTasks.indexWhere((t) => t.id == updated.id);
    if (idx1 != -1) {
      _todayTasks[idx1] = updated;
    }
    final idx2 = _unscheduledTasks.indexWhere((t) => t.id == updated.id);
    if (idx2 != -1) {
      _unscheduledTasks[idx2] = updated;
    }
    _persist();
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _todayTasks.removeWhere((t) => t.id == taskId);
    _unscheduledTasks.removeWhere((t) => t.id == taskId);
    _todaySchedules.removeWhere((s) => s.taskId == taskId);
    _persist();
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId, {bool createActivity = true}) {
    final taskIndex = _todayTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _todayTasks[taskIndex];
      final newStatus = task.status == TaskStatus.completed
          ? TaskStatus.scheduled
          : TaskStatus.completed;

      _todayTasks[taskIndex] = task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // If completed and PKL task, check if activity should be linked
      if (newStatus == TaskStatus.completed &&
          task.category == TaskCategory.pkl &&
          createActivity) {
        final existingActivity = _recentActivities.any((a) => a.taskId == taskId);
        if (!existingActivity) {
          final schedule = _todaySchedules.firstWhere(
            (s) => s.taskId == taskId,
            orElse: () => Schedule(
              taskId: taskId,
              date: _selectedDate,
              startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 9, 0),
              endTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 10, 30),
            ),
          );

          final newActivity = Activity(
            taskId: taskId,
            title: task.title,
            description: task.description.isNotEmpty ? task.description : 'Menyelesaikan task ${task.title}',
            date: _selectedDate,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            category: task.category,
            isCompleted: true,
          );
          _recentActivities.insert(0, newActivity);
        }
      }
      _persist();
      notifyListeners();
    }
  }

  void addActivity(Activity activity) {
    _recentActivities.insert(0, activity);
    _persist();
    notifyListeners();
  }

  void editActivity(Activity updated) {
    final idx = _recentActivities.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _recentActivities[idx] = updated;
      _persist();
      notifyListeners();
    }
  }

  void deleteActivity(String activityId) {
    _recentActivities.removeWhere((a) => a.id == activityId);
    _persist();
    notifyListeners();
  }

  void addDocumentation(Documentation doc) {
    _documentationList.insert(0, doc);
    _persist();
    notifyListeners();
  }

  void deleteDocumentation(String docId) {
    _documentationList.removeWhere((d) => d.id == docId);
    _persist();
    notifyListeners();
  }

  void addLearningNote(LearningNote note) {
    _learningNotes.insert(0, note);
    _persist();
    notifyListeners();
  }

  void editLearningNote(String noteId, String content) {
    final idx = _learningNotes.indexWhere((n) => n.id == noteId);
    if (idx != -1) {
      _learningNotes[idx] = LearningNote(
        id: _learningNotes[idx].id,
        sessionId: _learningNotes[idx].sessionId,
        content: content,
      );
      _persist();
      notifyListeners();
    }
  }

  void deleteLearningNote(String noteId) {
    _learningNotes.removeWhere((n) => n.id == noteId);
    _persist();
    notifyListeners();
  }

  void addLearningGoal(LearningGoal goal) {
    _learningGoals.add(goal);
    _persist();
    notifyListeners();
  }

  void updateLearningGoal(String id, double newProgress) {
    final idx = _learningGoals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _learningGoals[idx] = _learningGoals[idx].copyWith(progress: newProgress);
      _persist();
      notifyListeners();
    }
  }

  void deleteLearningGoal(String goalId) {
    _learningGoals.removeWhere((g) => g.id == goalId);
    _persist();
    notifyListeners();
  }

  Task? getTaskById(String id) {
    try {
      return [..._todayTasks, ..._unscheduledTasks].firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Task? getTaskForSchedule(Schedule schedule) {
    return getTaskById(schedule.taskId);
  }

  // ── Global Search ──────────────────────────────────────

  List<dynamic> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();

    final results = <dynamic>[];
    for (final task in [..._todayTasks, ..._unscheduledTasks]) {
      if (task.title.toLowerCase().contains(q) ||
          task.description.toLowerCase().contains(q) ||
          task.tags.any((t) => t.toLowerCase().contains(q))) {
        results.add(task);
      }
    }
    for (final activity in _recentActivities) {
      if (activity.title.toLowerCase().contains(q) ||
          activity.description.toLowerCase().contains(q)) {
        results.add(activity);
      }
    }
    for (final note in _learningNotes) {
      if (note.content.toLowerCase().contains(q)) {
        results.add(note);
      }
    }
    for (final doc in _documentationList) {
      if (doc.description.toLowerCase().contains(q) ||
          doc.tags.any((t) => t.toLowerCase().contains(q))) {
        results.add(doc);
      }
    }
    return results;
  }

  // ── Load Data (Local First) ────────────────────────────

  Future<void> loadOverviewData() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final saved = await LocalStorageService.loadData();
      if (saved != null) {
        _todayTasks = (saved['todayTasks'] as List? ?? [])
            .map((m) => Task.fromMap(m as Map<String, dynamic>))
            .toList();
        _unscheduledTasks = (saved['unscheduledTasks'] as List? ?? [])
            .map((m) => Task.fromMap(m as Map<String, dynamic>))
            .toList();
        _todaySchedules = (saved['todaySchedules'] as List? ?? [])
            .map((m) => Schedule.fromMap(m as Map<String, dynamic>))
            .toList();
        _recentActivities = (saved['recentActivities'] as List? ?? [])
            .map((m) => Activity.fromMap(m as Map<String, dynamic>))
            .toList();
        _documentationList = (saved['documentationList'] as List? ?? [])
            .map((m) => Documentation.fromMap(m as Map<String, dynamic>))
            .toList();
        _learningGoals = (saved['learningGoals'] as List? ?? [])
            .map((m) => LearningGoal.fromMap(m as Map<String, dynamic>))
            .toList();
        _learningNotes = (saved['learningNotes'] as List? ?? [])
            .map((m) => LearningNote.fromMap(m as Map<String, dynamic>))
            .toList();

        final prof = saved['userProfile'] as Map<String, dynamic>?;
        if (prof != null) {
          _userName = prof['userName'] ?? _userName;
          _userRole = prof['userRole'] ?? _userRole;
          _userCompany = prof['userCompany'] ?? _userCompany;
          _userMentor = prof['userMentor'] ?? _userMentor;
        }
      }
      // Jika `saved == null` (belum pernah ada data tersimpan), semua list
      // tetap pada nilai default kosong yang dideklarasikan di atas —
      // ditampilkan sebagai empty state asli, bukan data contoh.
    } catch (e) {
      // Gagal membaca storage lokal (file korup, dsb). Jangan diam-diam
      // isi data palsu — tampilkan error state yang jujur agar user tahu
      // dan bisa retry (lihat jejaksaku.md #2: error & retry state).
      _loadError = 'Gagal memuat data lokal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alias eksplisit untuk tombol "Coba Lagi" di UI saat [loadError] terisi.
  Future<void> retryLoad() => loadOverviewData();
}
