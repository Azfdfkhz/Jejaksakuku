import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/data/services/documentation_storage_service.dart';
import 'package:jejak_saku/domain/models/models.dart';

class DocumentationPage extends StatefulWidget {
  const DocumentationPage({super.key});

  @override
  State<DocumentationPage> createState() => _DocumentationPageState();
}

class _DocumentationPageState extends State<DocumentationPage> {
  String _selectedTag = 'Semua';

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
                      'Dokumentasi & Bukti PKL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kumpulan foto, tangkapan layar, dan bukti kerja untuk lampiran laporan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddDocumentationDialog(context, vm);
                  },
                  icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                  label: const Text('Tambah Foto Dokumentasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tag Filters
            Row(
              children: [
                _buildTagFilter('Semua'),
                const SizedBox(width: 8),
                _buildTagFilter('Frontend'),
                const SizedBox(width: 8),
                _buildTagFilter('Dashboard'),
                const SizedBox(width: 8),
                _buildTagFilter('Meeting'),
                const SizedBox(width: 8),
                _buildTagFilter('Responsive'),
              ],
            ),
            const SizedBox(height: 20),

            // Gallery Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: vm.documentationList.length,
              itemBuilder: (ctx, idx) {
                final doc = vm.documentationList[idx];
                return _buildPhotoCard(doc);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagFilter(String tag) {
    final isSelected = _selectedTag == tag;
    return ChoiceChip(
      label: Text(tag),
      selected: isSelected,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      onSelected: (_) => setState(() => _selectedTag = tag),
    );
  }

  Widget _brokenImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 6),
          Text(
            'File belum tersedia di device ini',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(Documentation doc) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview gambar asli dari file yang tersimpan di disk.
          // Jika file tidak ditemukan (misal belum sync dari device lain),
          // tampilkan empty/broken state yang jujur, bukan gambar palsu.
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: DocumentationStorageService.fileExists(doc.imagePath)
                          ? Image.file(
                              File(doc.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _brokenImagePlaceholder(),
                            )
                          : _brokenImagePlaceholder(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${doc.time.hour.toString().padLeft(2, '0')}:${doc.time.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Caption & tags
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: doc.tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '#$t',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentationDialog(BuildContext context, OverviewViewModel vm) {
    final descCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    File? pickedFile;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> pickImage() async {
            try {
              final result = await DocumentationStorageService.pickImageFile();
              if (result != null) {
                setDialogState(() => pickedFile = result);
              }
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Gagal membuka pemilih foto: $e')),
                );
              }
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Tambah Foto Dokumentasi',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: pickImage,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: pickedFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(pickedFile!, fit: BoxFit.cover, width: double.infinity, height: 140),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.primary),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ketuk untuk pilih foto asli',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      hintText: 'Deskripsi dokumentasi...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tagCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tags (pisahkan koma: Frontend, PKL)',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: (pickedFile == null || isSaving)
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          final savedPath = await DocumentationStorageService.saveImageFile(pickedFile!);
                          final tags = tagCtrl.text
                              .split(',')
                              .map((t) => t.trim())
                              .where((t) => t.isNotEmpty)
                              .toList();
                          final doc = Documentation(
                            imagePath: savedPath,
                            description: descCtrl.text.trim(),
                            date: vm.selectedDate,
                            time: DateTime.now(),
                            tags: tags,
                          );
                          vm.addDocumentation(doc);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✓ Foto dokumentasi tersimpan ke disk.'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan foto: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(isSaving ? 'Menyimpan...' : 'Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }
}
