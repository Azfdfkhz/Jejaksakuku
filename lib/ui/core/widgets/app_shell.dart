import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  
  const AppShell({
    super.key, 
    required this.child,
    this.title = 'Overview',
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: onItemSelected,
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(title: title),
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
