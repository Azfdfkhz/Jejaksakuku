import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/data/services/supabase_sync_service.dart';
import 'package:jejak_saku/data/services/drive_backup_service.dart';

class SyncManagementDialog extends StatefulWidget {
  const SyncManagementDialog({super.key});

  @override
  State<SyncManagementDialog> createState() => _SyncManagementDialogState();
}

class _SyncManagementDialogState extends State<SyncManagementDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  final _drivePathController = TextEditingController();
  final _googleDriveController = TextEditingController();

  final _supabaseService = SupabaseSyncService();
  final _driveService = DriveBackupService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _urlController.text = _supabaseService.url.isNotEmpty ? _supabaseService.url : 'https://your-project.supabase.co';
    _keyController.text = _supabaseService.anonKey;
    _drivePathController.text = _driveService.localDrivePath;
    _googleDriveController.text = _driveService.googleDriveAccount;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _keyController.dispose();
    _drivePathController.dispose();
    _googleDriveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Container(
        width: 620,
        height: 560,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penghubung Database Supabase & Drive',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Sinkronisasi multi-device & pencadangan data otomatis',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.storage_rounded, size: 18), text: 'Supabase Database'),
                Tab(icon: Icon(Icons.add_to_drive_rounded, size: 18), text: 'Drive & Cadangan'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSupabaseTab(context, vm),
                  _buildDriveTab(context, vm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupabaseTab(BuildContext context, OverviewViewModel vm) {
    return ListenableBuilder(
      listenable: _supabaseService,
      builder: (ctx, _) {
        final isConnected = _supabaseService.isConfigured;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isConnected ? const Color(0xFF81C784) : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFFB45309),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? 'Terhubung dengan Database Supabase' : 'Database Supabase Belum Terhubung',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFFB45309),
                            ),
                          ),
                          Text(
                            isConnected
                                ? 'Sinkronisasi aktif • Terakhir: ${_supabaseService.lastSyncTime}'
                                : 'Masukkan URL dan Anon Key untuk menghubungkan desktop dan mobile.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isConnected ? const Color(0xFF2E7D32) : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Inputs
              Text(
                'Supabase Project URL',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'https://xxxx.supabase.co',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
              const SizedBox(height: 14),

              Text(
                'Supabase Anon / Public Key',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                obscureText: true,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
              if (_supabaseService.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _supabaseService.errorMessage!,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await _supabaseService.initialize(
                        url: _urlController.text,
                        anonKey: _keyController.text,
                      );
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Berhasil terhubung ke Supabase!'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: const Text('Simpan & Sambungkan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final success = await _supabaseService.syncAll(
                        tasks: [...vm.todayTasks, ...vm.unscheduledTasks],
                        activities: vm.recentActivities,
                        schedules: vm.todaySchedules,
                        documentation: vm.documentationList,
                        goals: vm.learningGoals,
                        notes: vm.learningNotes,
                        userProfile: {
                          'userName': vm.userName,
                          'userRole': vm.userRole,
                          'userCompany': vm.userCompany,
                          'userMentor': vm.userMentor,
                        },
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Data lokal disinkronkan ke Supabase!'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Sinkronkan Sekarang'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // SQL Schema generator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skrip Tabel Database Supabase',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Salin query SQL untuk membuat tabel di Supabase SQL Editor',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final sql = _supabaseService.generateSupabaseSQL();
                      Clipboard.setData(ClipboardData(text: sql));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Skrip SQL Supabase berhasil disalin ke Clipboard!'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    icon: const Icon(Icons.content_copy_rounded, size: 14),
                    label: const Text('Salin Skrip SQL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDriveTab(BuildContext context, OverviewViewModel vm) {
    return ListenableBuilder(
      listenable: _driveService,
      builder: (ctx, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google Drive Account Connection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_to_drive_rounded, color: Color(0xFF1EA362), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Drive Cloud Backup',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _driveService.isGoogleDriveLinked
                                ? 'Tersambung: ${_driveService.googleDriveAccount}'
                                : 'Belum tersambung ke Google Drive',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_driveService.isGoogleDriveLinked) {
                          _driveService.unlinkGoogleDrive();
                        } else {
                          _driveService.linkGoogleDrive(_googleDriveController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Akun Google Drive tersambung untuk auto-backup!'), behavior: SnackBarBehavior.floating),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _driveService.isGoogleDriveLinked ? Colors.red : const Color(0xFF1EA362),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_driveService.isGoogleDriveLinked ? 'Putuskan' : 'Sambungkan'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Local Drive Folder Path
              Text(
                'Lokasi Penyimpanan Drive / Folder Lokal',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _drivePathController,
                      decoration: const InputDecoration(
                        hintText: r'D:\JejakSaku\',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _driveService.setLocalDrivePath(_drivePathController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lokasi Drive diperbarui ke "${_drivePathController.text}"!'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terapkan'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Backup Now Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pencadangan Instan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Terakhir: ${_driveService.lastBackupTime}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _driveService.isBackingUp
                          ? null
                          : () async {
                              final path = await _driveService.backupNow(
                                fullData: {
                                  'todayTasks': vm.todayTasks.map((t) => t.toMap()).toList(),
                                  'unscheduledTasks': vm.unscheduledTasks.map((t) => t.toMap()).toList(),
                                  'activities': vm.recentActivities.map((a) => a.toMap()).toList(),
                                  'documentation': vm.documentationList.map((d) => d.toMap()).toList(),
                                  'goals': vm.learningGoals.map((g) => g.toMap()).toList(),
                                  'notes': vm.learningNotes.map((n) => n.toMap()).toList(),
                                  'profile': {
                                    'name': vm.userName,
                                    'role': vm.userRole,
                                    'company': vm.userCompany,
                                    'mentor': vm.userMentor,
                                  },
                                },
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('✓ Backup tersimpan ke Drive: $path'), behavior: SnackBarBehavior.floating),
                                );
                              }
                            },
                      icon: const Icon(Icons.backup_rounded, size: 16),
                      label: Text(_driveService.isBackingUp ? 'Memproses...' : 'Backup ke Drive Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
