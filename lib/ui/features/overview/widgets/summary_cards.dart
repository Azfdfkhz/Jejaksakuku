import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. PKL Card
        Expanded(
          child: _buildMetricCard(
            icon: Icons.work_outline_rounded,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
            title: 'PKL',
            timeText: vm.pklSchedule,
            badgeText: 'Hadir',
            badgeBg: const Color(0xFFE8F5E9),
            badgeColor: const Color(0xFF2E7D32),
            progress: 1.0,
            progressColor: const Color(0xFF10B981),
            percentText: '100%',
          ),
        ),
        const SizedBox(width: 16),

        // 2. Learning Card
        Expanded(
          child: _buildMetricCard(
            icon: Icons.school_outlined,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: AppColors.learningPurple,
            title: 'Learning',
            timeText: '19:00 - 20:00',
            badgeText: 'Next.js',
            badgeBg: const Color(0xFFF3E8FF),
            badgeColor: AppColors.learningPurple,
            progress: 0.60,
            progressColor: AppColors.learningPurple,
            percentText: '60%',
          ),
        ),
        const SizedBox(width: 16),

        // 3. Progress Hari Ini Card
        Expanded(
          child: _buildMetricCard(
            icon: Icons.star_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: 'Progress Hari Ini',
            timeText: '${vm.completedTasks} / ${vm.totalTasks} Task selesai',
            badgeText: null,
            badgeBg: null,
            badgeColor: null,
            progress: vm.progressPercent,
            progressColor: const Color(0xFF10B981),
            percentText: null,
          ),
        ),
        const SizedBox(width: 16),

        // 4. Motivational Banner with Mountain Graphic
        Expanded(
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    width: 140,
                    child: CustomPaint(
                      painter: _MountainBannerPainter(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Langkah kecil hari ini, jadi\ncerita besar nanti.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String timeText,
    required String? badgeText,
    required Color? badgeBg,
    required Color? badgeColor,
    required double progress,
    required Color progressColor,
    required String? percentText,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(14),
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
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      timeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFF1F4F9),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 5,
                  ),
                ),
              ),
              if (percentText != null) ...[
                const SizedBox(width: 8),
                Text(
                  percentText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MountainBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background light sky tint
    final skyPaint = Paint()..color = const Color(0xFFF0F5FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Distant mountain
    final distantPaint = Paint()..color = const Color(0xFFD6E4FF);
    final pathDistant = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.5, h * 0.35)
      ..lineTo(w * 0.9, h)
      ..close();
    canvas.drawPath(pathDistant, distantPaint);

    // Mid mountain
    final midPaint = Paint()..color = const Color(0xFF93C5FD);
    final pathMid = Path()
      ..moveTo(w * 0.25, h)
      ..lineTo(w * 0.7, h * 0.2)
      ..lineTo(w * 1.1, h)
      ..close();
    canvas.drawPath(pathMid, midPaint);

    // Foreground mountain
    final forePaint = Paint()..color = const Color(0xFF3B82F6);
    final pathFore = Path()
      ..moveTo(w * 0.45, h)
      ..lineTo(w * 0.85, h * 0.15)
      ..lineTo(w * 1.2, h)
      ..close();
    canvas.drawPath(pathFore, forePaint);

    // Snow peak
    final snowPaint = Paint()..color = Colors.white;
    final snowPath = Path()
      ..moveTo(w * 0.85, h * 0.15)
      ..lineTo(w * 0.78, h * 0.35)
      ..lineTo(w * 0.85, h * 0.30)
      ..lineTo(w * 0.92, h * 0.35)
      ..close();
    canvas.drawPath(snowPath, snowPaint);

    // Orange Flagpole and Flag
    final polePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.85, h * 0.15),
      Offset(w * 0.85, h * 0.05),
      polePaint,
    );

    final flagPaint = Paint()..color = const Color(0xFFF97316);
    final flagPath = Path()
      ..moveTo(w * 0.85, h * 0.05)
      ..lineTo(w * 0.98, h * 0.10)
      ..lineTo(w * 0.85, h * 0.15)
      ..close();
    canvas.drawPath(flagPath, flagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
