import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';

class UpcomingScheduleWidget extends StatelessWidget {
  const UpcomingScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<OverviewViewModel>();

    final items = [
      {'time': '19:00', 'title': 'Belajar Next.js', 'cat': 'Learning', 'color': AppColors.learningPurple},
      {'time': '21:00', 'title': 'Review Dokumentasi', 'cat': 'PKL', 'color': AppColors.primary},
      {'time': 'Besok\n08:00', 'title': 'PKL - Pengembangan Fitur', 'cat': 'PKL', 'color': AppColors.primary},
      {'time': 'Besok\n19:00', 'title': 'Belajar UI/UX', 'cat': 'Learning', 'color': AppColors.learningPurple},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Jadwal Berikutnya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    // Navigate to Calendar
                  },
                  child: Text(
                    'Lihat semua →',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: items.map((item) {
                final time = item['time'] as String;
                final title = item['title'] as String;
                final cat = item['cat'] as String;
                final color = item['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
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
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
