import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/domain/models/models.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;

  const AddTaskDialog({super.key, this.initialStartTime, this.initialEndTime});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskCategory _category = TaskCategory.pkl;
  bool _scheduleNow = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  @override
  void initState() {
    super.initState();
    if (widget.initialStartTime != null) {
      _startTime = TimeOfDay(hour: widget.initialStartTime!.hour, minute: widget.initialStartTime!.minute);
      _scheduleNow = true;
    }
    if (widget.initialEndTime != null) {
      _endTime = TimeOfDay(hour: widget.initialEndTime!.hour, minute: widget.initialEndTime!.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Task Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title input
              Text(
                'Judul Task',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Contoh: Membuat Dashboard Website',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul task tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category selector
              Text(
                'Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildCategoryRadio(TaskCategory.pkl, 'PKL', AppColors.primary),
                  const SizedBox(width: 8),
                  _buildCategoryRadio(TaskCategory.learning, 'Learning', AppColors.learningPurple),
                  const SizedBox(width: 8),
                  _buildCategoryRadio(TaskCategory.personal, 'Personal', AppColors.personalYellow),
                ],
              ),
              const SizedBox(height: 14),

              // Schedule switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwalkan Langsung',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Switch(
                    value: _scheduleNow,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _scheduleNow = val;
                      });
                    },
                  ),
                ],
              ),

              if (_scheduleNow) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mulai', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: _startTime);
                              if (picked != null) setState(() => _startTime = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: _endTime);
                              if (picked != null) setState(() => _endTime = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),

              // Tags input
              Text(
                'Tags (pisahkan dengan koma)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: 'Frontend, Next.js, Meeting',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final vm = context.read<OverviewViewModel>();
                        final tags = _tagsController.text
                            .split(',')
                            .map((t) => t.trim())
                            .where((t) => t.isNotEmpty)
                            .toList();

                        final task = Task(
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          category: _category,
                          tags: tags,
                        );

                        if (_scheduleNow) {
                          final now = vm.selectedDate;
                          final start = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
                          final end = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);
                          vm.addTask(task, startTime: start, endTime: end);
                        } else {
                          vm.addTask(task);
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task "${task.title}" berhasil ditambahkan!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Simpan Task',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRadio(TaskCategory category, String label, Color color) {
    final isSelected = _category == category;
    return InkWell(
      onTap: () {
        setState(() {
          _category = category;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
