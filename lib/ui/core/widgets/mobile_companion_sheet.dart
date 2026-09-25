import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:jejak_saku/ui/core/theme/app_colors.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/data/services/documentation_storage_service.dart';
import 'package:jejak_saku/domain/models/models.dart';

class CommandMessageItem {
  final bool isUser;
  final String text;
  final Widget? customContent;
  final DateTime timestamp;

  CommandMessageItem({
    required this.isUser,
    required this.text,
    this.customContent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class MobileCompanionSheet extends StatefulWidget {
  const MobileCompanionSheet({super.key});

  @override
  State<MobileCompanionSheet> createState() => _MobileCompanionSheetState();
}

class _MobileCompanionSheetState extends State<MobileCompanionSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CommandMessageItem> _messages = [];
  bool _showSuggestions = false;

  final List<Map<String, String>> _availableCommands = [
    {'cmd': '/task', 'desc': 'Lihat atau buat task hari ini'},
    {'cmd': '/jadwal', 'desc': 'Lihat jadwal waktu hari ini'},
    {'cmd': '/dokumentasi', 'desc': 'Kirim foto dokumentasi PKL'},
    {'cmd': '/aktivitas', 'desc': 'Catat aktivitas PKL baru'},
    {'cmd': '/belajar', 'desc': 'Mulai / catat sesi belajar'},
    {'cmd': '/catatan', 'desc': 'Simpan catatan cepat'},
    {'cmd': '/status', 'desc': 'Ringkasan progress hari ini'},
    {'cmd': '/besok', 'desc': 'Rencana kegiatan besok'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      CommandMessageItem(
        isUser: false,
        text: 'Halo Rizky! Field Companion siap digunakan. Ketik / untuk melihat daftar perintah cepat.',
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleCommand(String rawInput, OverviewViewModel vm) {
    final input = rawInput.trim();
    if (input.isEmpty) return;

    _inputController.clear();
    setState(() {
      _showSuggestions = false;
      _messages.add(CommandMessageItem(isUser: true, text: input));
    });

    final lower = input.toLowerCase();

    if (lower.startsWith('/status')) {
      _respondStatus(vm);
    } else if (lower.startsWith('/task')) {
      _respondTask(vm);
    } else if (lower.startsWith('/jadwal')) {
      _respondJadwal(vm);
    } else if (lower.startsWith('/dokumentasi')) {
      _respondDokumentasi(vm);
    } else if (lower.startsWith('/aktivitas')) {
      final desc = input.replaceFirst(RegExp(r'/aktivitas\s*', caseSensitive: false), '');
      _respondAktivitas(vm, desc);
    } else if (lower.startsWith('/catatan')) {
      final note = input.replaceFirst(RegExp(r'/catatan\s*', caseSensitive: false), '');
      _respondCatatan(vm, note);
    } else if (lower.startsWith('/belajar')) {
      _respondBelajar(vm);
    } else if (lower.startsWith('/besok')) {
      _respondBesok(vm);
    } else {
      setState(() {
        _messages.add(
          CommandMessageItem(
            isUser: false,
            text: 'Perintah tidak dikenali. Ketik / untuk melihat daftar perintah yang tersedia.',
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _respondStatus(OverviewViewModel vm) {
    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: '',
          customContent: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today\'s Progress', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${vm.completedTasks}/${vm.totalTasks} Selesai', style: GoogleFonts.plusJakartaSans(color: AppColors.completedGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('✓ ${vm.completedTasks} task selesai', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.completedGreen)),
                Text('○ ${vm.totalTasks - vm.completedTasks} task tersisa', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.attentionOrange)),
                const SizedBox(height: 8),
                Text('Berikutnya: 19:00 Belajar Next.js', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('PKL: Hadir (08:00 - 16:00)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _respondTask(OverviewViewModel vm) {
    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: '',
          customContent: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daftar Task Hari Ini:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ...vm.todayTasks.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        t.status == TaskStatus.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16,
                        color: t.status == TaskStatus.completed ? AppColors.completedGreen : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            decoration: t.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _respondJadwal(OverviewViewModel vm) {
    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: '',
          customContent: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jadwal Waktu Hari Ini:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ...vm.todaySchedules.map((s) {
                  final task = vm.getTaskForSchedule(s);
                  final timeStr = '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')} - ${s.endTime.hour.toString().padLeft(2, '0')}:${s.endTime.minute.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $timeStr  ${task?.title ?? "Kegiatan"}', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _respondDokumentasi(OverviewViewModel vm) {
    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: 'Tambahkan foto dokumentasi:',
          customContent: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Foto Dokumentasi PKL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Builder(builder: (ctx) {
                  final activeTask = vm.todayTasks
                      .where((t) => t.status == TaskStatus.inProgress)
                      .cast<Task?>()
                      .firstOrNull;
                  return Text(
                    activeTask != null
                        ? 'Akan dihubungkan dengan task aktif: "${activeTask.title}"'
                        : 'Belum ada task yang sedang berjalan — dokumentasi disimpan tanpa link task.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await DocumentationStorageService.pickImageFile(fromCamera: true);
                    if (picked == null) return;
                    final savedPath = await DocumentationStorageService.saveImageFile(picked);
                    final activeTask = vm.todayTasks
                        .where((t) => t.status == TaskStatus.inProgress)
                        .cast<Task?>()
                        .firstOrNull;
                    final doc = Documentation(
                      imagePath: savedPath,
                      description: activeTask != null
                          ? 'Dokumentasi untuk task: ${activeTask.title}'
                          : 'Dokumentasi via Mobile Field Companion',
                      date: DateTime.now(),
                      time: DateTime.now(),
                      tags: const ['Mobile'],
                    );
                    vm.addDocumentation(doc);
                    if (!mounted) return;
                    setState(() {
                      _messages.add(
                        CommandMessageItem(
                          isUser: false,
                          text: '✓ Foto tersimpan di disk & dokumentasi tercatat${activeTask != null ? ' (terhubung task "${activeTask.title}").' : '.'}',
                        ),
                      );
                    });
                    _scrollToBottom();
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Ambil Foto / Pilih Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _respondAktivitas(OverviewViewModel vm, String desc) {
    if (desc.isEmpty) {
      setState(() {
        _messages.add(
          CommandMessageItem(
            isUser: false,
            text: 'Format: /aktivitas [Nama Kegiatan].\nContoh: /aktivitas Memperbaiki responsive navbar',
          ),
        );
      });
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newAct = Activity(
      title: desc,
      description: 'Dicatat via Mobile Field Companion',
      date: today,
      startTime: now,
      endTime: now.add(const Duration(minutes: 30)),
      category: TaskCategory.pkl,
      isCompleted: true,
    );
    vm.addActivity(newAct);

    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: '✓ Aktivitas PKL tersimpan: "$desc" ($timeStr). Data otomatis tersedia untuk laporan & presentasi.',
        ),
      );
    });
  }

  void _respondCatatan(OverviewViewModel vm, String note) {
    if (note.isEmpty) {
      setState(() {
        _messages.add(
          CommandMessageItem(
            isUser: false,
            text: 'Format: /catatan [Teks Catatan].\nContoh: /catatan Navbar masih mengalami overflow pada layar kecil.',
          ),
        );
      });
      return;
    }

    final activeSession = vm.currentLearningSession;
    final newNote = LearningNote(
      sessionId: activeSession?.id,
      content: note,
    );
    vm.addLearningNote(newNote);

    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: '✓ Catatan tersimpan: "$note"',
        ),
      );
    });
  }

  void _respondBelajar(OverviewViewModel vm) {
    final session = vm.currentLearningSession;
    final task = session != null ? vm.getTaskForSchedule(session) : null;

    if (session == null || task == null) {
      setState(() {
        _messages.add(
          CommandMessageItem(
            isUser: false,
            text: 'Belum ada sesi belajar yang dijadwalkan hari ini. Tambahkan lewat halaman Schedule di desktop/mobile.',
          ),
        );
      });
      return;
    }

    final timeStr = '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')} - '
        '${session.endTime.hour.toString().padLeft(2, '0')}:${session.endTime.minute.toString().padLeft(2, '0')}';
    final durationMin = session.endTime.difference(session.startTime).inMinutes;

    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: 'Sesi Belajar Hari Ini:',
          customContent: StatefulBuilder(
            builder: (ctx, setLocalState) {
              final isStarted = task.status == TaskStatus.inProgress;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.learningPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.learningPurple.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.learningPurple)),
                    const SizedBox(height: 4),
                    Text('Jadwal: $timeStr ($durationMin menit)', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: isStarted
                          ? null
                          : () {
                              vm.editTask(task.copyWith(status: TaskStatus.inProgress));
                              setLocalState(() {});
                              setState(() {
                                _messages.add(CommandMessageItem(isUser: false, text: '✓ Sesi belajar "${task.title}" dimulai! Fokus dan catat temuan penting.'));
                              });
                              _scrollToBottom();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.learningPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(isStarted ? 'Sedang Berjalan' : 'Mulai Sekarang'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _respondBesok(OverviewViewModel vm) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final schedules = vm.upcomingSchedules.where((s) {
      final d = s.date;
      return d.year == tomorrow.year && d.month == tomorrow.month && d.day == tomorrow.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (schedules.isEmpty) {
      setState(() {
        _messages.add(
          CommandMessageItem(
            isUser: false,
            text: 'Belum ada rencana kegiatan untuk besok. Tambahkan task/jadwal di halaman Schedule.',
          ),
        );
      });
      return;
    }

    final lines = schedules.map((s) {
      final task = vm.getTaskForSchedule(s);
      final timeStr = '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')} - '
          '${s.endTime.hour.toString().padLeft(2, '0')}:${s.endTime.minute.toString().padLeft(2, '0')}';
      return '• $timeStr  ${task?.title ?? "Kegiatan"}';
    }).join('\n');

    setState(() {
      _messages.add(
        CommandMessageItem(
          isUser: false,
          text: 'Rencana Kegiatan Besok:\n\n$lines',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OverviewViewModel>();

    return Center(
      child: Container(
        width: 440,
        height: 640,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              centerTitle: false,
              title: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.phone_android_rounded, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field Companion',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Command Center Mobile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // Quick command pills
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: AppColors.surface,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickPill('/status', vm),
                        _buildQuickPill('/task', vm),
                        _buildQuickPill('/dokumentasi', vm),
                        _buildQuickPill('/aktivitas', vm),
                        _buildQuickPill('/jadwal', vm),
                        _buildQuickPill('/belajar', vm),
                        _buildQuickPill('/catatan', vm),
                        _buildQuickPill('/besok', vm),
                      ],
                    ),
                  ),
                ),

                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, idx) {
                      final msg = _messages[idx];
                      return _buildMessageBubble(msg);
                    },
                  ),
                ),

                // Autocomplete suggestion overlay
                if (_showSuggestions)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _availableCommands.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final cmd = _availableCommands[idx];
                        return ListTile(
                          dense: true,
                          title: Text(cmd['cmd']!, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          subtitle: Text(cmd['desc']!, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                          onTap: () {
                            _inputController.text = '${cmd['cmd']} ';
                            _inputController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _inputController.text.length),
                            );
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),

                // Input bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded, size: 20, color: AppColors.textSecondary),
                        onPressed: () {
                          _handleCommand('/dokumentasi', vm);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: 'Ketik perintah / ...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          onChanged: (val) {
                            setState(() {
                              _showSuggestions = val.startsWith('/');
                            });
                          },
                          onSubmitted: (val) => _handleCommand(val, vm),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, size: 20, color: AppColors.primary),
                        onPressed: () => _handleCommand(_inputController.text, vm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPill(String cmd, OverviewViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(cmd),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        side: const BorderSide(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () => _handleCommand(cmd, vm),
      ),
    );
  }

  Widget _buildMessageBubble(CommandMessageItem msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14).copyWith(bottomRight: const Radius.circular(2)),
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14).copyWith(bottomLeft: const Radius.circular(2)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            if (msg.customContent != null) ...[
              if (msg.text.isNotEmpty) const SizedBox(height: 6),
              msg.customContent!,
            ],
          ],
        ),
      ),
    );
  }
}
