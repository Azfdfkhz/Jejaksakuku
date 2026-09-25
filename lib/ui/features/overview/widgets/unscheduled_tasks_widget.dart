import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';
import 'package:jejak_saku/ui/core/widgets/add_task_dialog.dart';

class UnscheduledTasksWidget extends StatelessWidget {
  const UnscheduledTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count badge
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task Belum Dijadwalkan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${vm.unscheduledTasks.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // List of Draggable Task Cards
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                ...vm.unscheduledTasks.map((task) => _buildDraggableCard(context, task, vm)),

                const SizedBox(height: 8),

                // Bottom Dashed Helper Area (matching design)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD3E2FA),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Tarik kartu tugas ke jadwal untuk menjadwalkan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(BuildContext context, Task task, OverviewViewModel vm) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    final titleLower = task.title.toLowerCase();
    if (titleLower.contains('revisi') || titleLower.contains('homepage')) {
      iconBg = const Color(0xFFE8F1FC);
      iconColor = AppColors.primary;
      icon = Icons.edit_outlined;
    } else if (titleLower.contains('flutter') || task.category == TaskCategory.learning) {
      iconBg = const Color(0xFFF3E8FF);
      iconColor = AppColors.learningPurple;
      icon = Icons.phone_android_rounded;
    } else if (titleLower.contains('dokumentasi')) {
      iconBg = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
      icon = Icons.description_outlined;
    } else if (titleLower.contains('laporan')) {
      iconBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      icon = Icons.article_outlined;
    } else {
      iconBg = const Color(0xFFFEE2E2);
      iconColor = const Color(0xFFDC2626);
      icon = Icons.storage_rounded;
    }

    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  task.tags.isNotEmpty
                      ? task.tags.join(' · ')
                      : task.category.name.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onSelected: (val) {
              if (val == 'schedule') {
                showDialog(
                  context: context,
                  builder: (ctx) => AddTaskDialog(
                    initialStartTime: DateTime(2026, 9, 25, 14, 0),
                    initialEndTime: DateTime(2026, 9, 25, 15, 30),
                  ),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'schedule',
                child: Text('Jadwalkan sekarang'),
              ),
            ],
          ),
        ],
      ),
    );

    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 260,
          child: Opacity(
            opacity: 0.9,
            child: cardContent,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: cardContent,
      ),
      child: cardContent,
    );
  }
}
