import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Aktivitas Terbaru',
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
                    // Navigate to Activities
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
              children: vm.recentActivities.map((act) {
                return _buildActivityItem(act);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Activity act) {
    Color iconBg;
    Color iconColor;
    IconData icon;
    Widget statusIndicator;

    final titleLower = act.title.toLowerCase();
    if (titleLower.contains('dashboard') || titleLower.contains('tampilan') || act.category == TaskCategory.pkl) {
      if (titleLower.contains('meeting') || titleLower.contains('pembimbing')) {
        iconBg = const Color(0xFFE8F1FC);
        iconColor = AppColors.primary;
        icon = Icons.groups_outlined;
        statusIndicator = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      } else {
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
        icon = Icons.work_outline_rounded;
        statusIndicator = Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 12, color: Color(0xFF059669)),
        );
      }
    } else {
      iconBg = const Color(0xFFF3E8FF);
      iconColor = AppColors.learningPurple;
      icon = Icons.school_outlined;
      statusIndicator = Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
        ),
      );
    }

    final startStr = '${act.startTime.hour.toString().padLeft(2, '0')}:${act.startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${act.endTime.hour.toString().padLeft(2, '0')}:${act.endTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
                  act.title,
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
                  '$startStr - $endStr',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          statusIndicator,
        ],
      ),
    );
  }
}
