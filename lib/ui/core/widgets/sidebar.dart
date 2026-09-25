import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Logo, title, subtitle & close icon
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bookmark_added_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jejak Saku',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Catat kegiatan. Atur waktu.\nKumpulkan bukti. Siap untuk laporan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _buildNavItem(0, 'Overview', Icons.home_outlined),
                const SizedBox(height: 16),
                _buildSectionHeader('PLANNING'),
                _buildNavItem(1, 'Today', Icons.today_outlined),
                _buildNavItem(2, 'Calendar', Icons.calendar_today_outlined),
                const SizedBox(height: 16),
                _buildSectionHeader('PKL'),
                _buildNavItem(3, 'Activities', Icons.work_outline_rounded),
                _buildNavItem(4, 'Documentation', Icons.image_outlined),
                const SizedBox(height: 16),
                _buildSectionHeader('LEARNING'),
                _buildNavItem(5, 'Schedule', Icons.schedule_outlined),
                _buildNavItem(6, 'Goals', Icons.flag_outlined),
                _buildNavItem(7, 'Notes', Icons.edit_note_rounded),
                const SizedBox(height: 16),
                _buildSectionHeader('OUTPUT'),
                _buildNavItem(8, 'Reports', Icons.insert_chart_outlined_rounded),
                _buildNavItem(9, 'Presentation', Icons.slideshow_outlined),
                const SizedBox(height: 16),
                _buildSectionHeader('SYSTEM'),
                _buildNavItem(10, 'Settings', Icons.settings_outlined),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // User Profile Card at bottom (RP - Rizky Pratama)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        'RP',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.completedGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rizky Pratama',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'SMK RPL - PKL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.completedGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Online',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.completedGreen,
                            ),
                          ),
                        ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.09) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
