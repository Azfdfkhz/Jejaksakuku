import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
                      'Laporan PKL Otomatis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Otomatis terisi dari aktivitas, jadwal, dan dokumentasi yang telah kamu catat.',
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
                          const SnackBar(content: Text('Laporan dalam format Markdown disalin!'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin Markdown'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menyiapkan file cetak / PDF Laporan PKL...'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('Export PDF Resmi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics Summary
            Row(
              children: [
                _buildStatBox('Hari Pelaksanaan', '42 Hari', Icons.calendar_today_outlined, AppColors.primary),
                const SizedBox(width: 14),
                _buildStatBox('Total Aktivitas', '${vm.recentActivities.length + 120}', Icons.work_outline_rounded, AppColors.completedGreen),
                const SizedBox(width: 14),
                _buildStatBox('Dokumentasi Foto', '${vm.documentationList.length + 80} Item', Icons.image_outlined, AppColors.learningPurple),
                const SizedBox(width: 14),
                _buildStatBox('Proyek Selesai', '3 Proyek', Icons.folder_special_outlined, AppColors.personalYellow),
              ],
            ),
            const SizedBox(height: 24),

            // Report Preview Sheet
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'LAPORAN PRAKTIK KERJA LAPANGAN (PKL)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SMK NEGERI BIDANG KEAHLIAN REKAYASA PERANGKAT LUNAK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Periode: 1 Agustus 2026 - 30 September 2026',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(thickness: 1.5, color: AppColors.border),
                  const SizedBox(height: 20),

                  // Section 1: Profil
                  _buildSectionHeader('I. IDENTITAS SISWA & MITRA INDUSTRI'),
                  const SizedBox(height: 10),
                  _buildKeyValueRow('Nama Siswa', 'Rizky Pratama'),
                  _buildKeyValueRow('Program Keahlian', 'Pengembangan Perangkat Lunak & Gim (PPLG / RPL)'),
                  _buildKeyValueRow('Tempat PKL', 'PT Solusi Teknologi Nusantara'),
                  _buildKeyValueRow('Pembimbing Industri', 'Bapak Hendra Wijaya, S.Kom'),
                  const SizedBox(height: 24),

                  // Section 2: Ringkasan Tugas
                  _buildSectionHeader('II. RINGKASAN CAPAIAN KERJA & PROYEK'),
                  const SizedBox(height: 10),
                  Text(
                    'Selama masa PKL, siswa berkontribusi pada pengembangan sistem manajemen internal dan dashboard website menggunakan teknologi modern (Next.js, Tailwind CSS, dan Flutter). Pekerjaan mencakup perancangan arsitektur antarmuka, optimasi kinerja frontend, dan integrasi API RESTful.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.6, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Rekap Aktivitas
                  _buildSectionHeader('III. REKAPITULASI AKTIVITAS TERBARU'),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: AppColors.border, width: 1),
                    columnWidths: const {
                      0: FixedColumnWidth(90),
                      1: FlexColumnWidth(3),
                      2: FixedColumnWidth(110),
                      3: FixedColumnWidth(80),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                        children: [
                          _buildTableCell('Waktu', isHeader: true),
                          _buildTableCell('Nama Aktivitas / Kegiatan', isHeader: true),
                          _buildTableCell('Kategori', isHeader: true),
                          _buildTableCell('Status', isHeader: true),
                        ],
                      ),
                      ...vm.recentActivities.map((act) => TableRow(
                        children: [
                          _buildTableCell('${act.startTime.hour.toString().padLeft(2, '0')}:${act.startTime.minute.toString().padLeft(2, '0')}'),
                          _buildTableCell(act.title),
                          _buildTableCell(act.category.name.toUpperCase()),
                          _buildTableCell(act.isCompleted ? 'Selesai' : 'Proses'),
                        ],
                      )),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              key,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
