import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/ui/features/overview/widgets/today_planner_widget.dart';
import 'package:jejak_saku/ui/features/overview/widgets/unscheduled_tasks_widget.dart';
import 'package:jejak_saku/ui/core/widgets/add_task_dialog.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rencana Hari Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Atur jadwal tugas, blok waktu fokus, dan catat progres harianmu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const AddTaskDialog(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today Planner + Unscheduled Columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 5,
                  child: TodayPlannerWidget(),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  flex: 3,
                  child: UnscheduledTasksWidget(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary of Today's Completion
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
                    'Evaluasi Jadwal Hari Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricBox('Total Tugas', '${vm.totalTasks}', AppColors.primary),
                      const SizedBox(width: 12),
                      _buildMetricBox('Selesai', '${vm.completedTasks}', AppColors.completedGreen),
                      const SizedBox(width: 12),
                      _buildMetricBox('Tersisa', '${vm.totalTasks - vm.completedTasks}', AppColors.attentionOrange),
                      const SizedBox(width: 12),
                      _buildMetricBox('Progres', '${(vm.progressPercent * 100).toInt()}%', AppColors.learningPurple),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
