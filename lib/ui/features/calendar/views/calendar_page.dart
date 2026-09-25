import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDay = 25;
  TaskCategory? _selectedFilter;

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalender Kegiatan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'September 2026 • Monitoring kehadiran, bimbingan, dan target belajar.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Category filters
                Row(
                  children: [
                    _buildFilterChip('Semua', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('PKL', TaskCategory.pkl),
                    const SizedBox(width: 8),
                    _buildFilterChip('Learning', TaskCategory.learning),
                    const SizedBox(width: 8),
                    _buildFilterChip('Personal', TaskCategory.personal),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calendar Grid + Day Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month View Card
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                              'September 2026',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, size: 20),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, size: 20),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Day headers
                        Row(
                          children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((d) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Month Grid (30 days in September)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: 35, // with offset
                          itemBuilder: (ctx, idx) {
                            final day = idx - 1; // start on Tuesday
                            if (day < 1 || day > 30) {
                              return const SizedBox();
                            }

                            final isSelected = day == _selectedDay;
                            final isToday = day == 25;
                            final hasPKL = day >= 1 && day <= 25 && idx % 7 != 0 && idx % 7 != 6;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDay = day;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isToday
                                          ? AppColors.primary.withValues(alpha: 0.1)
                                          : AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : isToday
                                            ? AppColors.primary
                                            : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (hasPKL) ...[
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.white : AppColors.completedGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          if (day == 25 || day == 24) ...[
                                            const SizedBox(width: 2),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: isSelected ? Colors.white : AppColors.learningPurple,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Selected Day Schedule Details
                Expanded(
                  flex: 3,
                  child: Container(
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
                          'Jadwal $_selectedDay September 2026',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDay == 25 ? 'Hari Ini • 4 Jadwal' : '3 Jadwal Tersimpan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        ...vm.todaySchedules.map((s) {
                          final task = vm.getTaskForSchedule(s);
                          if (task == null) return const SizedBox();

                          if (_selectedFilter != null && task.category != _selectedFilter) {
                            return const SizedBox();
                          }

                          final startStr = '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')}';
                          final endStr = '${s.endTime.hour.toString().padLeft(2, '0')}:${s.endTime.minute.toString().padLeft(2, '0')}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: task.category == TaskCategory.pkl
                                            ? AppColors.primary
                                            : AppColors.learningPurple,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    '$startStr - $endStr',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskCategory? category) {
    final isSelected = _selectedFilter == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      onSelected: (_) {
        setState(() {
          _selectedFilter = category;
        });
      },
    );
  }
}
