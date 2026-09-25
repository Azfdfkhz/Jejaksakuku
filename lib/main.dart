import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jejak_saku/ui/core/theme/app_theme.dart';
import 'package:jejak_saku/ui/core/widgets/app_shell.dart';
import 'package:jejak_saku/ui/core/widgets/search_dialog.dart';
import 'package:jejak_saku/ui/core/widgets/quick_capture_dialog.dart';
import 'package:jejak_saku/ui/features/overview/view_models/overview_view_model.dart';
import 'package:jejak_saku/ui/features/overview/views/overview_page.dart';
import 'package:jejak_saku/ui/features/today/views/today_page.dart';
import 'package:jejak_saku/ui/features/calendar/views/calendar_page.dart';
import 'package:jejak_saku/ui/features/pkl/activities/views/activities_page.dart';
import 'package:jejak_saku/ui/features/pkl/documentation/views/documentation_page.dart';
import 'package:jejak_saku/ui/features/learning/schedule/views/learning_schedule_page.dart';
import 'package:jejak_saku/ui/features/learning/goals/views/learning_goals_page.dart';
import 'package:jejak_saku/ui/features/learning/notes/views/learning_notes_page.dart';
import 'package:jejak_saku/ui/features/reports/views/reports_page.dart';
import 'package:jejak_saku/ui/features/presentation/views/presentation_page.dart';
import 'package:jejak_saku/ui/features/settings/views/settings_page.dart';

void main() {
  runApp(const JejakSakuApp());
}

class JejakSakuApp extends StatelessWidget {
  const JejakSakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OverviewViewModel()),
      ],
      child: MaterialApp(
        title: 'Jejak Saku',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = [
    'Overview',
    'Today',
    'Calendar',
    'Activities',
    'Documentation',
    'Schedule',
    'Goals',
    'Notes',
    'Reports',
    'Presentation',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OverviewViewModel>().loadOverviewData();
    });
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return const OverviewPage();
      case 1:
        return const TodayPage();
      case 2:
        return const CalendarPage();
      case 3:
        return const ActivitiesPage();
      case 4:
        return const DocumentationPage();
      case 5:
        return const LearningSchedulePage();
      case 6:
        return const LearningGoalsPage();
      case 7:
        return const LearningNotesPage();
      case 8:
        return const ReportsPage();
      case 9:
        return const PresentationPage();
      case 10:
        return const SettingsPage();
      default:
        return const OverviewPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          showDialog(
            context: context,
            builder: (ctx) => const SearchDialog(),
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          showDialog(
            context: context,
            builder: (ctx) => const QuickCaptureDialog(initialType: 0),
          );
        },
      },
      child: Focus(
        autofocus: true,
        child: AppShell(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          title: _pageTitles[_selectedIndex],
          child: _buildPageContent(_selectedIndex),
        ),
      ),
    );
  }
}
