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

  DateTime _selectedDate = DateTime(2026, 9, 25);
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── User Profile ───────────────────────────────────────

  String _userName = 'Rizky Pratama';
  String get userName => _userName;

  String _userRole = 'SMK RPL - PKL';
  String get userRole => _userRole;

  String _userCompany = 'PT Solusi Teknologi Nusantara';
  String get userCompany => _userCompany;

  String _userMentor = 'Hendra Wijaya, S.Kom';
  String get userMentor => _userMentor;

  String get userStatus => 'Online';
  String get greetingName => _userName.split(' ').first;

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

  Map<String, double> get learningProgress {
    if (_learningGoals.isEmpty) {
      return {
        'Next.js': 0.70,
        'Flutter': 0.50,
        'UI/UX': 0.60,
        'Blender': 0.30,
      };
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

  void resetToDefaultData() {
    _loadSampleData();
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
    _selectedDate = DateTime(2026, 9, 25);
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
      } else {
        _loadSampleData();
        _persist();
      }
    } catch (_) {
      _loadSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSampleData() {
    final now = _selectedDate;
    final today = DateTime(now.year, now.month, now.day);

    _todayTasks = [
      Task(
        id: 't1',
        title: 'PKL - Membuat Dashboard Website',
        description: 'Membangun komponen overview dashboard dengan Flutter dan Next.js',
        category: TaskCategory.pkl,
        status: TaskStatus.completed,
        tags: ['Frontend', 'Next.js'],
      ),
      Task(
        id: 't2',
        title: 'Meeting Pembimbing',
        description: 'Diskusi progress mingguan proyek PKL bersama pembimbing industri',
        category: TaskCategory.pkl,
        status: TaskStatus.inProgress,
        tags: ['Meeting'],
      ),
      Task(
        id: 't3',
        title: 'Revisi Website',
        description: 'Perbaikan layout responsive dan penyesuaian styling Tailwind',
        category: TaskCategory.pkl,
        status: TaskStatus.completed,
        tags: ['Frontend', 'Tailwind'],
      ),
      Task(
        id: 't4',
        title: 'Belajar Next.js',
        description: 'Eksplorasi Server Components dan App Router',
        category: TaskCategory.learning,
        status: TaskStatus.scheduled,
        tags: ['Learning'],
      ),
      Task(
        id: 't5',
        title: 'Review Dokumentasi',
        description: 'Mengecek kelengkapan foto dan logbook PKL',
        category: TaskCategory.pkl,
        status: TaskStatus.scheduled,
        tags: ['PKL'],
      ),
    ];

    _todaySchedules = [
      Schedule(
        id: 's1',
        taskId: 't1',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 8, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 30),
      ),
      Schedule(
        id: 's2',
        taskId: 't2',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 11, 0),
        endTime: DateTime(now.year, now.month, now.day, 12, 0),
      ),
      Schedule(
        id: 's3',
        taskId: 't3',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 13, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 0),
      ),
      Schedule(
        id: 's4',
        taskId: 't4',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 19, 0),
        endTime: DateTime(now.year, now.month, now.day, 20, 0),
      ),
    ];

    _unscheduledTasks = [
      Task(
        id: 'u1',
        title: 'Revisi Homepage',
        category: TaskCategory.pkl,
        status: TaskStatus.unscheduled,
        tags: ['PKL', 'Frontend'],
      ),
      Task(
        id: 'u2',
        title: 'Belajar Flutter',
        category: TaskCategory.learning,
        status: TaskStatus.unscheduled,
        tags: ['Learning', 'Mobile'],
      ),
      Task(
        id: 'u3',
        title: 'Dokumentasi Project',
        category: TaskCategory.pkl,
        status: TaskStatus.unscheduled,
        tags: ['PKL', 'Dokumentasi'],
      ),
      Task(
        id: 'u4',
        title: 'Buat Laporan Mingguan',
        category: TaskCategory.pkl,
        status: TaskStatus.unscheduled,
        tags: ['Report', 'Administrasi'],
      ),
      Task(
        id: 'u5',
        title: 'Backup Data',
        category: TaskCategory.personal,
        status: TaskStatus.unscheduled,
        tags: ['Sistem', 'Maintenance'],
      ),
    ];

    final tomorrow = today.add(const Duration(days: 1));
    _upcomingSchedules = [
      Schedule(
        id: 'up1',
        taskId: 't4',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 19, 0),
        endTime: DateTime(now.year, now.month, now.day, 20, 0),
      ),
      Schedule(
        id: 'up2',
        taskId: 't5',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 21, 0),
        endTime: DateTime(now.year, now.month, now.day, 22, 0),
      ),
      Schedule(
        id: 'up3',
        taskId: 't1',
        date: tomorrow,
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
      ),
      Schedule(
        id: 'up4',
        taskId: 'u2',
        date: tomorrow,
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 19, 0),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20, 0),
      ),
    ];

    _recentActivities = [
      Activity(
        id: 'a1',
        title: 'Membuat dashboard website',
        description: 'Slicing UI dashboard dan implementasi data fetching',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 30),
        category: TaskCategory.pkl,
        isCompleted: true,
      ),
      Activity(
        id: 'a2',
        title: 'Meeting dengan pembimbing',
        description: 'Evaluasi mingguan dan review rancangan database',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 11, 0),
        endTime: DateTime(now.year, now.month, now.day, 12, 0),
        category: TaskCategory.pkl,
        isCompleted: false,
      ),
      Activity(
        id: 'a3',
        title: 'Revisi tampilan website',
        description: 'Perbaikan responsivitas layout tablet dan mobile',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 13, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 0),
        category: TaskCategory.pkl,
        isCompleted: true,
      ),
      Activity(
        id: 'a4',
        title: 'Belajar Next.js',
        description: 'Mempelajari implementasi Server Actions & Cache Revalidation',
        date: today,
        startTime: DateTime(now.year, now.month, now.day, 19, 0),
        endTime: DateTime(now.year, now.month, now.day, 20, 0),
        category: TaskCategory.learning,
        isCompleted: false,
      ),
    ];

    _documentationList = [
      Documentation(
        id: 'd1',
        activityId: 'a1',
        imagePath: 'assets/doc1.png',
        description: 'Tampilan dashboard awal yang berhasil dislicing',
        date: today,
        time: DateTime(now.year, now.month, now.day, 10, 30),
        tags: ['Frontend', 'Dashboard', 'PKL'],
      ),
      Documentation(
        id: 'd2',
        activityId: 'a2',
        imagePath: 'assets/doc2.png',
        description: 'Sesi bimbingan bersama mentor industri',
        date: today,
        time: DateTime(now.year, now.month, now.day, 11, 45),
        tags: ['Meeting', 'Bimbingan'],
      ),
      Documentation(
        id: 'd3',
        activityId: 'a3',
        imagePath: 'assets/doc3.png',
        description: 'Inspeksi layout navbar pada mobile breakpoint',
        date: today,
        time: DateTime(now.year, now.month, now.day, 14, 20),
        tags: ['CSS', 'Responsive'],
      ),
    ];

    _learningGoals = [
      LearningGoal(
        id: 'g1',
        title: 'Master Next.js App Router',
        description: 'Server components, streaming, dynamic routes',
        targetDate: today.add(const Duration(days: 30)),
        progress: 0.70,
      ),
      LearningGoal(
        id: 'g2',
        title: 'Flutter Desktop & Mobile Development',
        description: 'State management, custom paint, responsive layout',
        targetDate: today.add(const Duration(days: 45)),
        progress: 0.50,
      ),
      LearningGoal(
        id: 'g3',
        title: 'Prinsip UI/UX & Design System',
        description: 'Typography, visual hierarchy, spacing, accessibility',
        targetDate: today.add(const Duration(days: 20)),
        progress: 0.60,
      ),
      LearningGoal(
        id: 'g4',
        title: 'Blender 3D Asset Modeling',
        description: 'Low poly modeling dan export glTF',
        targetDate: today.add(const Duration(days: 60)),
        progress: 0.30,
      ),
    ];

    _learningNotes = [
      LearningNote(
        id: 'n1',
        sessionId: 's4',
        content: 'Server Actions di Next.js dapat dipanggil langsung dari client component tanpa membuat API route manual.',
      ),
      LearningNote(
        id: 'n2',
        sessionId: 's4',
        content: 'Gunakan `revalidatePath` untuk memperbarui cache halaman secara on-demand setelah mutasi data.',
      ),
      LearningNote(
        id: 'n3',
        sessionId: 's4',
        content: 'Prinsip local-first: simpan semua interaksi ke SQLite lokal terlebih dahulu agar aplikasi tetap cepat & offline-ready.',
      ),
    ];
  }
}
