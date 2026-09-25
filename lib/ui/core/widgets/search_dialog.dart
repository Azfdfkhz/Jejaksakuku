import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();
    final results = vm.search(_query);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Container(
        width: 640,
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Cari tugas, aktivitas, catatan, atau dokumentasi...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _query = val;
                        });
                      },
                    ),
                  ),
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _query = '';
                        });
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'ESC',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results or Empty State
            Expanded(
              child: _query.trim().isEmpty
                  ? _buildRecentSearches()
                  : results.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ditemukan hasil untuk "$_query"',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (ctx, idx) {
                            final item = results[idx];
                            return _buildResultTile(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SARAN PENCARIAN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Dashboard'),
              _buildSuggestionChip('Next.js'),
              _buildSuggestionChip('Meeting'),
              _buildSuggestionChip('Dokumentasi'),
              _buildSuggestionChip('Laporan PKL'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textPrimary),
      backgroundColor: AppColors.background,
      side: const BorderSide(color: AppColors.border),
      onPressed: () {
        setState(() {
          _controller.text = text;
          _query = text;
        });
      },
    );
  }

  Widget _buildResultTile(dynamic item) {
    IconData icon;
    Color iconColor;
    String typeLabel;
    String title;
    String subtitle;

    if (item is Task) {
      icon = Icons.check_circle_outline;
      iconColor = AppColors.primary;
      typeLabel = 'TASK';
      title = item.title;
      subtitle = item.description.isNotEmpty ? item.description : item.category.name.toUpperCase();
    } else if (item is Activity) {
      icon = Icons.work_outline;
      iconColor = AppColors.completedGreen;
      typeLabel = 'AKTIVITAS PKL';
      title = item.title;
      subtitle = item.description;
    } else if (item is LearningNote) {
      icon = Icons.note_outlined;
      iconColor = AppColors.learningPurple;
      typeLabel = 'CATATAN';
      title = item.content;
      subtitle = 'Catatan Belajar';
    } else if (item is Documentation) {
      icon = Icons.image_outlined;
      iconColor = AppColors.attentionOrange;
      typeLabel = 'DOKUMENTASI';
      title = item.description;
      subtitle = item.tags.join(', ');
    } else {
      icon = Icons.article_outlined;
      iconColor = AppColors.textSecondary;
      typeLabel = 'ITEM';
      title = item.toString();
      subtitle = '';
    }

    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              typeLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
