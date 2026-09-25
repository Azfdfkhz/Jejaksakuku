import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/ui/core/widgets/sync_management_dialog.dart';
import 'package:jejak_saku/data/services/supabase_sync_service.dart';
import 'package:jejak_saku/data/services/drive_backup_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoSync = true;
  bool _offlineMode = true;

  void _showEditProfileDialog(BuildContext context, OverviewViewModel vm) {
    final nameCtrl = TextEditingController(text: vm.userName);
    final roleCtrl = TextEditingController(text: vm.userRole);
    final companyCtrl = TextEditingController(text: vm.userCompany);
    final mentorCtrl = TextEditingController(text: vm.userMentor);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.person_pin_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Edit Data Profil Asli', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah identitas diri agar laporan PKL, dokumentasi, dan sinkronisasi sesuai data riil Anda.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap Siswa / Pengguna', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Peran / Jurusan / Posisi (mis: SMK RPL - PKL Frontend)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Instansi / Perusahaan Tempat PKL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mentorCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Pembimbing Industri / Guru Mentor', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              vm.updateUserProfile(
                name: nameCtrl.text,
                role: roleCtrl.text,
                company: companyCtrl.text,
                mentor: mentorCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Profil berhasil diperbarui!'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Simpan Profil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Text(
              'Pengaturan Sistem',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola profil pengguna, preferensi sinkronisasi, dan penyimpanan data lokal.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      'RP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vm.userName,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vm.userRole} • PT Solusi Teknologi Nusantara',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.completedGreen, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Status Sinkronisasi: Online', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.completedGreen, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileDialog(context, vm),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profil Data Asli'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Supabase & Cloud Drive Integration Card
            AnimatedBuilder(
              animation: Listenable.merge([SupabaseSyncService(), DriveBackupService()]),
              builder: (context, _) {
                final supa = SupabaseSyncService();
                final drive = DriveBackupService();

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                    'Koneksi Supabase & Google Drive',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    'Sinkronisasi lintas perangkat PostgreSQL & pencadangan berkala Drive',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const SyncManagementDialog(),
                              );
                            },
                            icon: const Icon(Icons.settings_input_composite_rounded, size: 16),
                            label: const Text('Konfigurasi Cloud & Drive'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.table_restaurant_rounded,
                                        size: 16,
                                        color: supa.isConfigured ? const Color(0xFF10B981) : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Supabase PostgreSQL',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: supa.isConfigured ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          supa.isConfigured ? 'Terkoneksi' : 'Belum Terhubung',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: supa.isConfigured ? const Color(0xFF2E7D32) : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    supa.isConfigured ? supa.url : 'Masukkan Project URL & Anon Key di menu konfigurasi',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.add_to_drive_rounded,
                                        size: 16,
                                        color: drive.isGoogleDriveLinked ? const Color(0xFF2563EB) : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Drive & Disk Storage',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: drive.isGoogleDriveLinked ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          drive.isGoogleDriveLinked ? 'Google Drive Linked' : 'Folder Lokal',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: drive.isGoogleDriveLinked ? const Color(0xFF1D4ED8) : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${drive.localDrivePath} (Cadangan: ${drive.lastBackupTime})',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: supa.getSchemaSqlScript()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✓ Schema SQL Supabase disalin ke clipboard! Tempelkan di Supabase SQL Editor.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.code_rounded, size: 16),
                            label: const Text('Salin Schema SQL'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final path = await drive.backupNow(fullData: vm.exportAllDataAsJson());
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✓ Cadangan berhasil dibuat: $path'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.backup_outlined, size: 16),
                            label: const Text('Cadangkan Data Sekarang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Sync & Storage Preferences
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arsitektur Local-First & Preferensi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jejak Saku mengutamakan penyimpanan offline di perangkat lokal, kemudian menyelaraskannya ke Supabase dan Google Drive.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Local-First Offline Ready', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Semua penambahan data langsung disimpan ke file JSON/SQLite lokal terlebih dahulu tanpa membutuhkan internet.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                    value: _offlineMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _offlineMode = val),
                  ),
                  const Divider(height: 1),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Otomatis Sinkronisasi ke Supabase', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('Menyelaraskan data secara berkala setiap 5 menit atau saat terhubung ke internet.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                    value: _autoSync,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _autoSync = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About App
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jejak Saku v1.0.0', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Plan your day. Capture your work. Keep your progress.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
