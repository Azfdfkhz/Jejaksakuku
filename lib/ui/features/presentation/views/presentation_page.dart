import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key});

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  int _activeSlide = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Slide 1: Pembukaan & Profil Perusahaan',
      'subtitle': 'Laporan Akhir Praktik Kerja Lapangan',
      'content': [
        'Nama Siswa: Rizky Pratama (SMK RPL)',
        'Mitra Industri: PT Solusi Teknologi Nusantara',
        'Pembimbing: Bapak Hendra Wijaya, S.Kom',
        'Fokus Divisi: Frontend & Mobile Application Development',
      ],
      'icon': Icons.business_outlined,
      'color': AppColors.primary,
    },
    {
      'title': 'Slide 2: Proyek Utama PKL',
      'subtitle': 'Pengembangan Dashboard Manajemen & Portal Web',
      'content': [
        'Membangun dashboard monitoring kegiatan menggunakan Next.js & Tailwind CSS',
        'Implementasi reactive state management dan antarmuka responsif',
        'Optimasi Core Web Vitals untuk pengalaman pengguna yang cepat dan mulus',
      ],
      'icon': Icons.web_asset_rounded,
      'color': AppColors.completedGreen,
    },
    {
      'title': 'Slide 3: Rangkaian Aktivitas & Pemecahan Masalah',
      'subtitle': 'Solusi Tantangan Teknis di Lapangan',
      'content': [
        'Tantangan 1: Layout breakpoint mengalami overflow pada layar tablet.',
        'Solusi: Mengadopsi CSS Grid modular dan container queries modern.',
        'Tantangan 2: Sinkronisasi data offline saat koneksi terbatas.',
        'Solusi: Merancang strategi Local-First dengan antrian sinkronisasi lokal.',
      ],
      'icon': Icons.build_circle_outlined,
      'color': AppColors.personalYellow,
    },
    {
      'title': 'Slide 4: Galeri Dokumentasi & Bukti Kerja',
      'subtitle': 'Arsip Foto Lapangan & Sesi Bimbingan',
      'content': [
        '📷 Foto 1: Sesi standup meeting dan pembagian sprint mingguan',
        '📷 Foto 2: Review kode dan arsitektur basis data bersama mentor',
        '📷 Foto 3: Pengujian fungsionalitas dashboard lintas peramban',
      ],
      'icon': Icons.photo_library_outlined,
      'color': AppColors.learningPurple,
    },
    {
      'title': 'Slide 5: Capaian Kompetensi Belajar',
      'subtitle': 'Peningkatan Keterampilan Teknis & Soft Skills',
      'content': [
        'Penguasaan Next.js: 70% (Server Actions, App Router)',
        'Penguasaan Flutter: 50% (Cross-platform UI & State)',
        'Penguasaan UI/UX: 60% (Design Systems, Micro-interactions)',
        'Soft Skills: Komunikasi efektif, manajemen waktu, kerja sama tim',
      ],
      'icon': Icons.stars_rounded,
      'color': const Color(0xFF0D9488),
    },
    {
      'title': 'Slide 6: Kesimpulan & Penutup',
      'subtitle': 'Refleksi Akhir Program PKL',
      'content': [
        'PKL memberikan pengalaman nyata standar industri perangkat lunak',
        'Semua target dan luaran proyek berhasil diselesaikan tepat waktu',
        'Siap melanjutkan ke jenjang profesional dan ujian kompetensi keahlian',
      ],
      'icon': Icons.flag_circle_outlined,
      'color': AppColors.primary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<OverviewViewModel>();
    final current = _slides[_activeSlide];

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
                      'Persiapan Presentasi Sidang PKL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Struktur slide presentasi yang terorganisir otomatis dari catatan kerja harian.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Slide outline diexport ke format PPTX / Markdown.'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export Slide Deck'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Slide Navigation Thumbnails + Interactive Stage
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnails Sidebar
                SizedBox(
                  width: 240,
                  child: Column(
                    children: List.generate(_slides.length, (idx) {
                      final s = _slides[idx];
                      final isSelected = _activeSlide == idx;
                      return InkWell(
                        onTap: () => setState(() => _activeSlide = idx),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(s['icon'] as IconData, size: 18, color: s['color'] as Color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Slide ${idx + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 20),

                // Active Slide Stage
                Expanded(
                  child: Container(
                    height: 480,
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (current['color'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Slide ${_activeSlide + 1} dari ${_slides.length}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: current['color'] as Color,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                                  onPressed: _activeSlide > 0
                                      ? () => setState(() => _activeSlide--)
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                  onPressed: _activeSlide < _slides.length - 1
                                      ? () => setState(() => _activeSlide++)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          current['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          current['subtitle'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 20),

                        Expanded(
                          child: ListView(
                            children: (current['content'] as List<String>).map((point) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: current['color'] as Color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: AppColors.textPrimary,
                                        ),
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
