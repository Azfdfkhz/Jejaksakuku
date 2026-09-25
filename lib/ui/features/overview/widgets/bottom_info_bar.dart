import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/ui/core/widgets/add_task_dialog.dart';
import 'package:jejak_saku/ui/core/widgets/quick_capture_dialog.dart';
import 'package:jejak_saku/ui/core/widgets/sync_management_dialog.dart';
import 'package:jejak_saku/data/services/supabase_sync_service.dart';
import 'package:jejak_saku/data/services/drive_backup_service.dart';

class BottomInfoBar extends StatelessWidget {
  const BottomInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Quick Action Card (given adequate flex & 2-line clean buttons)
        Expanded(
          flex: 4,
          child: Container(
            height: 195,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Action',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.9,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // + Tambah Task (solid blue)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const AddTaskDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Tambah',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              'Task',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // + Tambah Aktivitas (white outlined)
                      _buildWhiteActionBtn(
                        line1: '+ Tambah',
                        line2: 'Aktivitas',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const QuickCaptureDialog(initialType: 1),
                          );
                        },
                      ),

                      // + Tambah Catatan (white outlined)
                      _buildWhiteActionBtn(
                        line1: '+ Tambah',
                        line2: 'Catatan',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const QuickCaptureDialog(initialType: 2),
                          );
                        },
                      ),

                      // Ctrl+N Quick Capture (white outlined)
                      _buildWhiteActionBtn(
                        line1: 'Ctrl + N',
                        line2: 'Quick Capture',
                        isShortcut: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const QuickCaptureDialog(initialType: 0),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 2. Progress Belajar Card
        Expanded(
          flex: 3,
          child: Container(
            height: 195,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress Belajar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Lihat detail →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...vm.learningProgress.entries.map((e) {
                  Color c = AppColors.learningPurple;
                  if (e.key.contains('Flutter')) c = const Color(0xFF0284C7);
                  if (e.key.contains('UI/UX')) c = const Color(0xFF0D9488);
                  if (e.key.contains('Blender')) c = const Color(0xFFF59E0B);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildSkillRow(e.key, e.value, c),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 3. Kutipan Hari Ini Card
        Expanded(
          flex: 3,
          child: Container(
            height: 195,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_quote_rounded, size: 18, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Text(
                          'Kutipan Hari Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '"${vm.dailyQuote}"',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.change_history_rounded,
                    size: 26,
                    color: const Color(0xFF10B981).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 4. Status Sistem Card (Interactive: tap to manage Supabase & Drive)
        Expanded(
          flex: 3,
          child: AnimatedBuilder(
            animation: Listenable.merge([SupabaseSyncService(), DriveBackupService()]),
            builder: (context, _) {
              final supa = SupabaseSyncService();
              final drive = DriveBackupService();
              final isOnline = supa.status == SyncStatus.synced || supa.status == SyncStatus.connecting;

              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const SyncManagementDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 195,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.dns_outlined, size: 16, color: AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text(
                                'Status Sistem',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOnline ? 'Online' : 'Local-First',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildSystemRow(Icons.folder_outlined, 'Data Location', drive.localDrivePath),
                      const SizedBox(height: 6),
                      _buildSystemRow(
                        Icons.cloud_sync_outlined,
                        'Supabase',
                        supa.isConfigured ? 'Terkoneksi' : 'Belum diatur',
                        textColor: supa.isConfigured ? const Color(0xFF10B981) : AppColors.textSecondary,
                        iconColor: supa.isConfigured ? const Color(0xFF10B981) : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 6),
                      _buildSystemRow(
                        Icons.backup_outlined,
                        'Drive Backup',
                        drive.isGoogleDriveLinked ? 'Linked' : 'Lokal',
                        textColor: drive.isGoogleDriveLinked ? const Color(0xFF2563EB) : AppColors.textSecondary,
                        iconColor: drive.isGoogleDriveLinked ? const Color(0xFF2563EB) : AppColors.textSecondary,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Kelola Cloud & Drive →',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWhiteActionBtn({
    required String line1,
    required String line2,
    bool isShortcut = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              line1,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isShortcut ? FontWeight.w700 : FontWeight.w600,
                color: isShortcut ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            Text(
              line2,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRow(String skill, double progress, Color barColor) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 52,
          child: Text(
            skill,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F4F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSystemRow(IconData icon, String label, String value, {Color? textColor, Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
