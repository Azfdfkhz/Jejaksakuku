import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/ui/core/widgets/add_task_dialog.dart';
import 'package:jejak_saku/domain/models/models.dart';
import 'package:jejak_saku/ui/core/utils/date_format_id.dart';

class TodayPlannerWidget extends StatelessWidget {
  const TodayPlannerWidget({super.key});

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
          // ── Clean 2-Row Header (prevents text squishing completely!) ──
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Title & "+ Tambah Task" Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today Planner',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const AddTaskDialog(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'Tambah Task',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Date Badge on Left, View Pills & Navigation on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatId.full(vm.selectedDate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // View Mode Pills: Hari / Minggu / Bulan
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              _buildModePill('Hari', vm.plannerViewMode == PlannerViewMode.hari, () {
                                vm.setPlannerViewMode(PlannerViewMode.hari);
                              }),
                              _buildModePill('Minggu', vm.plannerViewMode == PlannerViewMode.minggu, () {
                                vm.setPlannerViewMode(PlannerViewMode.minggu);
                              }),
                              _buildModePill('Bulan', vm.plannerViewMode == PlannerViewMode.bulan, () {
                                vm.setPlannerViewMode(PlannerViewMode.bulan);
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Date arrows < >
                        Row(
                          children: [
                            _buildIconButton(Icons.chevron_left, () => vm.previousDay()),
                            const SizedBox(width: 2),
                            _buildIconButton(Icons.chevron_right, () => vm.nextDay()),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Timeline Body or Week/Month View
          if (vm.plannerViewMode == PlannerViewMode.hari)
            _buildDayTimeline(context, vm)
          else if (vm.plannerViewMode == PlannerViewMode.minggu)
            _buildWeekTimeline(context, vm)
          else
            _buildMonthTimeline(context, vm),
        ],
      ),
    );
  }

  Widget _buildModePill(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
          color: AppColors.surface,
        ),
        child: Icon(icon, size: 15, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildDayTimeline(BuildContext context, OverviewViewModel vm) {
    final hours = [
      '08:00', '09:00', '10:00', '11:00', '12:00', '13:00',
      '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: hours.map((hour) {
          return _buildHourRow(context, hour, vm);
        }).toList(),
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, String hour, OverviewViewModel vm) {
    Schedule? schedule;
    for (final s in vm.todaySchedules) {
      final sHour = s.startTime.hour.toString().padLeft(2, '0');
      if ('$sHour:00' == hour) {
        schedule = s;
        break;
      }
    }

    final task = schedule != null ? vm.getTaskForSchedule(schedule) : null;
    final isSpecialHour = schedule != null || hour == '12:00' || hour == '21:00';

    return Padding(
      padding: EdgeInsets.only(bottom: isSpecialHour ? 10.0 : 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label on left
          SizedBox(
            width: 44,
            child: Text(
              hour,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isSpecialHour ? AppColors.textPrimary : AppColors.textSecondary.withValues(alpha: 0.6),
                fontWeight: isSpecialHour ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Content area
          Expanded(
            child: _buildTimelineContentForHour(context, hour, schedule, task, vm),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContentForHour(
    BuildContext context,
    String hour,
    Schedule? schedule,
    Task? task,
    OverviewViewModel vm,
  ) {
    // 1. Scheduled Task Card
    if (schedule != null && task != null) {
      Color dotColor = AppColors.primary;
      Color cardBg = const Color(0xFFF3F7FE);
      Color borderColor = const Color(0xFFD3E2FA);
      Color tagBg = const Color(0xFFE8F1FC);
      Color tagTextColor = AppColors.primary;

      if (task.category == TaskCategory.learning) {
        dotColor = AppColors.learningPurple;
        cardBg = const Color(0xFFFAF5FF);
        borderColor = const Color(0xFFE9D5FF);
        tagBg = const Color(0xFFF3E8FF);
        tagTextColor = AppColors.learningPurple;
      } else if (task.tags.contains('Meeting')) {
        dotColor = AppColors.personalYellow;
        cardBg = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        tagBg = const Color(0xFFFEF3C7);
        tagTextColor = const Color(0xFFB45309);
      }

      final startStr = '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}';
      final endStr = '${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}';
      final isCompleted = task.status == TaskStatus.completed;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    _handleTaskCompletionToggle(context, task, vm);
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.completedGreen : dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 11, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showEditTaskDialog(context, task, vm);
                    } else if (val == 'delete') {
                      vm.deleteTask(task.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task dihapus.'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Task')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus Task', style: TextStyle(color: Colors.red))),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.drag_indicator_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                '$startStr - $endStr',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Wrap(
                  spacing: 6,
                  children: task.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tagTextColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // 2. Lunch break line at 12:00
    if (hour == '12:00') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.add, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Istirahat / Makan Siang  12:00 - 13:00',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Drop Zone at 21:00
    if (hour == '21:00') {
      return DragTarget<Task>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (details) {
          final task = details.data;
          final date = vm.selectedDate;
          final start = DateTime(date.year, date.month, date.day, 21, 0);
          final end = DateTime(date.year, date.month, date.day, 22, 0);
          vm.scheduleUnscheduledTask(task, start, end);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" berhasil dijadwalkan pukul 21:00!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (ctx, candidateData, _) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            height: 38,
            decoration: BoxDecoration(
              color: isHovering ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF7FAFE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovering ? AppColors.primary : const Color(0xFFC7DCFA),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                '+ Tarik task di sini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      );
    }

    // 4. Subtle empty slot (drop target, compact height)
    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final task = details.data;
        final hourInt = int.tryParse(hour.split(':')[0]) ?? 10;
        final date = vm.selectedDate;
        final start = DateTime(date.year, date.month, date.day, hourInt, 0);
        final end = DateTime(date.year, date.month, date.day, hourInt + 1, 0);
        vm.scheduleUnscheduledTask(task, start, end);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" dijadwalkan pada $hour!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      builder: (ctx, candidateData, _) {
        if (candidateData.isNotEmpty) {
          return Container(
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary),
            ),
            child: Center(
              child: Text(
                'Jadwalkan pada $hour',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
        return Container(
          height: 12,
          alignment: Alignment.centerLeft,
          child: Container(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.4),
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, OverviewViewModel vm) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description);
    final tagsCtrl = TextEditingController(text: task.tags.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit Task', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul Task', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tagsCtrl,
              decoration: const InputDecoration(labelText: 'Tags (pisahkan koma)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                final tags = tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                final updated = task.copyWith(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  tags: tags,
                  updatedAt: DateTime.now(),
                );
                vm.editTask(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task berhasil diperbarui.'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleTaskCompletionToggle(BuildContext context, Task task, OverviewViewModel vm) {
    final willComplete = task.status != TaskStatus.completed;

    if (willComplete && task.category == TaskCategory.pkl) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.completedGreen, size: 22),
              const SizedBox(width: 8),
              Text(
                'Task Selesai',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah ingin menyimpan task ini sebagai aktivitas PKL resmi?\n(Data aktivitas akan otomatis digunakan pada laporan dan presentasi).',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                vm.toggleTaskCompletion(task.id, createActivity: false);
                Navigator.pop(ctx);
              },
              child: Text('Nanti', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                vm.toggleTaskCompletion(task.id, createActivity: true);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Aktivitas PKL berhasil dibuat dan terhubung!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.completedGreen,
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan Aktivitas', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    } else {
      vm.toggleTaskCompletion(task.id);
    }
  }

  Widget _buildWeekTimeline(BuildContext context, OverviewViewModel vm) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: days.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: d == 'Kam' ? FontWeight.bold : FontWeight.w500,
                    color: d == 'Kam' ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'Tampilan timeline mingguan aktif. Anda dapat memindahkan tugas antar hari.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...vm.todayTasks.map((t) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                t.status == TaskStatus.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: t.status == TaskStatus.completed ? AppColors.completedGreen : AppColors.primary,
                size: 18,
              ),
              title: Text(t.title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: Text(t.tags.join(', '), style: GoogleFonts.plusJakartaSans(fontSize: 11)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMonthTimeline(BuildContext context, OverviewViewModel vm) {
    final month = vm.selectedDate;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            DateFormatId.monthYear(month),
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.2,
            ),
            itemCount: daysInMonth,
            itemBuilder: (ctx, idx) {
              final day = idx + 1;
              final isToday = day == now.day && month.month == now.month && month.year == now.year;
              return Container(
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isToday ? AppColors.primary : AppColors.border),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
