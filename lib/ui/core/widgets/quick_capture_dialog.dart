import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';

class QuickCaptureDialog extends StatefulWidget {
  final int initialType; // 0: Task, 1: Activity, 2: Note

  const QuickCaptureDialog({super.key, this.initialType = 0});

  @override
  State<QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<QuickCaptureDialog> {
  late int _type; // 0: Task, 1: Activity, 2: Note
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final vm = context.read<OverviewViewModel>();

    if (_type == 0) {
      final task = Task(
        title: text,
        category: TaskCategory.pkl,
        tags: ['Quick Capture'],
      );
      vm.addTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Task "$text" disimpan ke backlog!'), behavior: SnackBarBehavior.floating),
      );
    } else if (_type == 1) {
      final now = DateTime.now();
      final act = Activity(
        title: text,
        description: 'Dicatat via Quick Capture',
        date: vm.selectedDate,
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        category: TaskCategory.pkl,
        isCompleted: true,
      );
      vm.addActivity(act);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Aktivitas PKL "$text" berhasil dicatat!'), behavior: SnackBarBehavior.floating),
      );
    } else {
      final note = LearningNote(
        sessionId: 's4',
        content: text,
      );
      vm.addLearningNote(note);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Catatan berhasil disimpan!'), behavior: SnackBarBehavior.floating),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Capture',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type selector pills
            Row(
              children: [
                _buildTypePill(0, 'Task', Icons.check_circle_outline),
                const SizedBox(width: 8),
                _buildTypePill(1, 'Aktivitas PKL', Icons.work_outline),
                const SizedBox(width: 8),
                _buildTypePill(2, 'Catatan', Icons.note_outlined),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _textController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _type == 0
                    ? 'Apa yang perlu dikerjakan?'
                    : _type == 1
                        ? 'Apa aktivitas PKL yang baru saja dilakukan?'
                        : 'Tulis ide atau temuan belajar...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tekan Enter untuk simpan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypePill(int type, String label, IconData icon) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
