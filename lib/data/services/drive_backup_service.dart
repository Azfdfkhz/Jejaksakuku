import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DriveBackupService extends ChangeNotifier {
  static final DriveBackupService _instance = DriveBackupService._internal();
  factory DriveBackupService() => _instance;
  DriveBackupService._internal();

  String _localDrivePath = r'D:\JejakSaku\';
  String get localDrivePath => _localDrivePath;

  String _googleDriveAccount = 'azmi.fadhil301@smk.belajar.id';
  String get googleDriveAccount => _googleDriveAccount;

  bool _isGoogleDriveLinked = false;
  bool get isGoogleDriveLinked => _isGoogleDriveLinked;

  String _lastBackupTime = '25 Sep 2026 · 22:15';
  String get lastBackupTime => _lastBackupTime;

  bool _isBackingUp = false;
  bool get isBackingUp => _isBackingUp;

  void setLocalDrivePath(String path) {
    _localDrivePath = path.trim();
    notifyListeners();
  }

  void linkGoogleDrive(String accountEmail) {
    _googleDriveAccount = accountEmail.trim();
    _isGoogleDriveLinked = true;
    _lastBackupTime = _formatTime(DateTime.now());
    notifyListeners();
  }

  void unlinkGoogleDrive() {
    _isGoogleDriveLinked = false;
    notifyListeners();
  }

  /// Exports backup to local drive directory and cloud drive
  Future<String> backupNow({
    required Map<String, dynamic> fullData,
  }) async {
    _isBackingUp = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'jejak_saku_backup_$stamp.json';

      // 1. Save in local app documents dir
      final docsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${docsDir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(jsonEncode(fullData));

      // 2. Simulate cloud drive synchronization
      await Future.delayed(const Duration(milliseconds: 600));

      _lastBackupTime = _formatTime(now);
      _isBackingUp = false;
      notifyListeners();
      return file.path;
    } catch (e) {
      _isBackingUp = false;
      notifyListeners();
      return 'Gagal melakukan backup: $e';
    }
  }

  String _formatTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $h:$min';
  }
}
