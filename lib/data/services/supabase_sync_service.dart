import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jejak_saku/domain/models/models.dart';
import 'package:http/http.dart' as http;

enum SyncStatus { disconnected, connecting, synced, syncing, error }

/// Supabase connector & sync service following Local-First architecture (CLAUDE.md #43 & #44).
///
/// Flow:
/// UI -> ViewModel -> Local DB / LocalStorage -> Sync Queue -> Supabase
class SupabaseSyncService extends ChangeNotifier {
  static final SupabaseSyncService _instance = SupabaseSyncService._internal();
  factory SupabaseSyncService() => _instance;
  SupabaseSyncService._internal();

  String _url = 'https://ffpzasgqarvxwugbkikg.supabase.co';
  String get url => _url;

  String _anonKey = 'sb_publishable_0Yfylvrx0rnzKzeei5JFkg_50W8-yr3';
  String get anonKey => _anonKey;

  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  SyncStatus _status = SyncStatus.disconnected;
  SyncStatus get status => _status;

  String _lastSyncTime = '-';
  String get lastSyncTime => _lastSyncTime;

  int _pendingChanges = 0;
  int get pendingChanges => _pendingChanges;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SupabaseClient? _client;
  SupabaseClient? get client => _client;

  /// Initialize Supabase with custom URL and anon key
  Future<bool> initialize({required String url, required String anonKey}) async {
    _url = url.trim();
    _anonKey = anonKey.trim();

    if (_url.isEmpty || _anonKey.isEmpty) {
      _status = SyncStatus.disconnected;
      _isConfigured = false;
      notifyListeners();
      return false;
    }

    _status = SyncStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      // Test basic connectivity via HTTP request first
      final testUrl = Uri.parse(_url.endsWith('/') ? '${_url}rest/v1/' : '$_url/rest/v1/');
      final res = await http.get(testUrl, headers: {
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      }).timeout(const Duration(seconds: 8));

      // Supabase REST endpoint returns 200 or 404 (openapi spec) when valid
      if (res.statusCode == 200 || res.statusCode == 404 || res.statusCode == 401) {
        try {
          await Supabase.initialize(
            url: _url,
            anonKey: _anonKey,
            debug: kDebugMode,
          );
          _client = Supabase.instance.client;
        } catch (_) {
          // If already initialized, get instance
          _client = Supabase.instance.client;
        }

        _isConfigured = true;
        _status = SyncStatus.synced;
        _lastSyncTime = _formatTime(DateTime.now());
        notifyListeners();
        return true;
      } else {
        _status = SyncStatus.error;
        _errorMessage = 'Respons server tidak sesuai (Status: ${res.statusCode})';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Gagal terhubung: Pastikan URL dan Anon Key Supabase valid.';
      notifyListeners();
      return false;
    }
  }

  /// Sync all local data up to Supabase tables
  Future<bool> syncAll({
    required List<Task> tasks,
    required List<Activity> activities,
    required List<Schedule> schedules,
    required List<Documentation> documentation,
    required List<LearningGoal> goals,
    required List<LearningNote> notes,
    required Map<String, dynamic> userProfile,
  }) async {
    if (!_isConfigured || _client == null) {
      _pendingChanges = tasks.length + activities.length;
      notifyListeners();
      return false;
    }

    _status = SyncStatus.syncing;
    notifyListeners();

    try {
      // 1. Sync User Profile
      await _client!.from('profiles').upsert({
        'id': userProfile['userName'] ?? 'default_user',
        'full_name': userProfile['userName'],
        'role': userProfile['userRole'],
        'company': userProfile['userCompany'],
        'mentor': userProfile['userMentor'],
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Sync Tasks
      for (final t in tasks) {
        await _client!.from('tasks').upsert({
          'id': t.id,
          'title': t.title,
          'description': t.description,
          'category': t.category.name,
          'status': t.status.name,
          'tags': t.tags,
          'updated_at': t.updatedAt.toIso8601String(),
        });
      }

      // 3. Sync Activities
      for (final a in activities) {
        await _client!.from('activities').upsert({
          'id': a.id,
          'task_id': a.taskId,
          'title': a.title,
          'description': a.description,
          'date': a.date.toIso8601String(),
          'start_time': a.startTime.toIso8601String(),
          'end_time': a.endTime.toIso8601String(),
          'category': a.category.name,
          'is_completed': a.isCompleted,
        });
      }

      // 4. Sync Schedules
      for (final s in schedules) {
        await _client!.from('schedules').upsert({
          'id': s.id,
          'task_id': s.taskId,
          'date': s.date.toIso8601String(),
          'start_time': s.startTime.toIso8601String(),
          'end_time': s.endTime.toIso8601String(),
        });
      }

      // 5. Sync Learning Goals
      for (final g in goals) {
        await _client!.from('learning_goals').upsert({
          'id': g.id,
          'title': g.title,
          'description': g.description,
          'progress': g.progress,
          'target_date': g.targetDate.toIso8601String(),
        });
      }

      // 6. Sync Notes
      for (final n in notes) {
        await _client!.from('learning_notes').upsert({
          'id': n.id,
          'session_id': n.sessionId,
          'content': n.content,
        });
      }

      _pendingChanges = 0;
      _status = SyncStatus.synced;
      _lastSyncTime = _formatTime(DateTime.now());
      notifyListeners();
      return true;
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = 'Gagal sinkronisasi data: $e';
      notifyListeners();
      return false;
    }
  }

  /// Alias for generateSupabaseSQL
  String getSchemaSqlScript() => generateSupabaseSQL();

  /// Generates the complete ready-to-run PostgreSQL SQL schema for Supabase
  String generateSupabaseSQL() {
    return '''
-- ===================================================
-- JEJAK SAKU - SUPABASE DATABASE SCHEMA
-- Jalankan skrip ini di SQL Editor di dashboard Supabase
-- ===================================================

-- 1. Tabel Profil Pengguna
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT,
  company TEXT,
  mentor TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabel Tasks
CREATE TABLE IF NOT EXISTS public.tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  category TEXT NOT NULL,
  status TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabel Schedules (Jadwal Waktu)
CREATE TABLE IF NOT EXISTS public.schedules (
  id TEXT PRIMARY KEY,
  task_id TEXT REFERENCES public.tasks(id) ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Tabel Aktivitas PKL
CREATE TABLE IF NOT EXISTS public.activities (
  id TEXT PRIMARY KEY,
  task_id TEXT,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  category TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tabel Dokumentasi Foto
CREATE TABLE IF NOT EXISTS public.documentation (
  id TEXT PRIMARY KEY,
  activity_id TEXT,
  image_path TEXT NOT NULL,
  description TEXT DEFAULT '',
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  time TIMESTAMP WITH TIME ZONE NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Tabel Target Belajar (Learning Goals)
CREATE TABLE IF NOT EXISTS public.learning_goals (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  progress REAL DEFAULT 0.0,
  target_date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Tabel Catatan Belajar (Notes)
CREATE TABLE IF NOT EXISTS public.learning_notes (
  id TEXT PRIMARY KEY,
  session_id TEXT,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documentation ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_notes ENABLE ROW LEVEL SECURITY;

-- Izinkan akses anon read/write untuk kebutuhan single-user PKL
CREATE POLICY "Allow anon all on profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on tasks" ON public.tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on schedules" ON public.schedules FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on activities" ON public.activities FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on documentation" ON public.documentation FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on learning_goals" ON public.learning_goals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on learning_notes" ON public.learning_notes FOR ALL USING (true) WITH CHECK (true);
''';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
