import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'asdos_home_screen.dart';
import 'activity_history_screen.dart';
import 'asdos_profile_screen.dart';

class AsdosShell extends StatefulWidget {
  const AsdosShell({super.key});

  @override
  State<AsdosShell> createState() => _AsdosShellState();
}

class _AsdosShellState extends State<AsdosShell> {
  int _idx = 0;

  final _pages = const [
    AsdosHomeScreen(),
    ActivityHistoryScreen(),
    AsdosProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: _pages),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border, width: 0.5))),
      child: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Aktivitas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
        ],
      ),
    ),
  );
}