import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';

class LearningGoalsPage extends StatelessWidget {
  const LearningGoalsPage({super.key});

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
                      'Target & Kompetensi Belajar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau progres penguasaan teknologi dan keterampilan pendukung selama periode PKL.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddGoalDialog(context);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Target'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.learningPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Goals Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: vm.learningGoals.length,
              itemBuilder: (ctx, idx) {
                final goal = vm.learningGoals[idx];
                return _buildGoalCard(context, goal, vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, LearningGoal goal, OverviewViewModel vm) {
    Color barColor;
    if (goal.title.contains('Next.js')) {
      barColor = AppColors.learningPurple;
    } else if (goal.title.contains('Flutter')) {
      barColor = const Color(0xFF0284C7);
    } else if (goal.title.contains('UI/UX')) {
      barColor = const Color(0xFF0D9488);
    } else {
      barColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    goal.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(goal.progress * 100).toInt()}% Selesai',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            goal.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tingkat Penguasaan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                  Text(
                    'Target: ${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: const Color(0xFFF1F4F9),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Tambah Target Belajar', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Nama Target (contoh: Database PostgreSQL & Supabase)',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Deskripsi kompetensi yang ingin dicapai...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Target belajar berhasil ditambahkan!'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.learningPurple),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
