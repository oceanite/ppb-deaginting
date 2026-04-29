import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dosen_home_screen.dart';
import 'approval_screen.dart';
import 'dosen_profile.dart';

class DosenShell extends StatefulWidget {
  const DosenShell({super.key});

  @override
  State<DosenShell> createState() => _DosenShellState();
}

class _DosenShellState extends State<DosenShell> {
  int _idx = 0;

  final _pages = const [
    DosenHomeScreen(),
    ApprovalScreen(),
    DosenProfile(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _idx, children: _pages),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: AppColors.border, width: 0.5))),
          child: BottomNavigationBar(
            currentIndex: _idx,
            onTap: (i) => setState(() => _idx = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Beranda'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.fact_check_rounded),
                  label: 'Review'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Profil'),
            ],
          ),
        ),
      );
}