import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/ui/features/overview/widgets/greeting_header.dart';
import 'package:jejak_saku/ui/features/overview/widgets/summary_cards.dart';
import 'package:jejak_saku/ui/features/overview/widgets/today_planner_widget.dart';
import 'package:jejak_saku/ui/features/overview/widgets/unscheduled_tasks_widget.dart';
import 'package:jejak_saku/ui/features/overview/widgets/upcoming_schedule_widget.dart';
import 'package:jejak_saku/ui/features/overview/widgets/recent_activity_widget.dart';
import 'package:jejak_saku/ui/features/overview/widgets/bottom_info_bar.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<OverviewViewModel>().loadOverviewData();
      }
    });
  }

  void _showDataManagementDialog(BuildContext context, OverviewViewModel vm) {
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
            const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Input & Kelola Data Asli',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
                  'Masukkan identitas asli Anda untuk ditampilkan di seluruh aplikasi, laporan, dan presentasi:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap Anda', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Jurusan / Sekolah (contoh: SMK RPL - PKL)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(labelText: 'Tempat / Perusahaan PKL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mentorCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Pembimbing Industri', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Opsi Data:',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: ctx,
                      builder: (confirmCtx) => AlertDialog(
                        title: const Text('Hapus semua data?'),
                        content: const Text('Semua task, jadwal, aktivitas, dokumentasi, dan catatan belajar akan dihapus permanen dari perangkat ini. Tindakan ini tidak bisa dibatalkan.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(confirmCtx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              vm.clearAllData();
                              Navigator.pop(confirmCtx);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Semua data berhasil dihapus.'), behavior: SnackBarBehavior.floating),
                              );
                            },
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: Colors.red),
                  label: const Text('Hapus Semua Data', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
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
                const SnackBar(content: Text('✓ Profil data asli Anda berhasil disimpan!'), behavior: SnackBarBehavior.floating),
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

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat data',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  vm.loadError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => vm.retryLoad(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header + Data Management Quick Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: GreetingHeader()),
                OutlinedButton.icon(
                  onPressed: () => _showDataManagementDialog(context, vm),
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primary),
                  label: Text(
                    'Input Data Asli / Profil',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryLight),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Top Metric Summary Cards
            const SummaryCards(),
            const SizedBox(height: 18),

            // Main Columns (Balanced flex: 5 for Planner, 3 for Unscheduled, 3 for Right Schedule/Activity)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 5,
                  child: TodayPlannerWidget(),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  flex: 3,
                  child: UnscheduledTasksWidget(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: const [
                      UpcomingScheduleWidget(),
                      SizedBox(height: 16),
                      RecentActivityWidget(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Bottom 4 Info Cards
            const BottomInfoBar(),
          ],
        ),
      ),
    );
  }
}
