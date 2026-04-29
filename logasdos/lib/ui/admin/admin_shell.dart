import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../provider/app_provider.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_user_screen.dart';
import 'admin_class_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _idx = 0;

  final _pages = const [
    AdminDashboardScreen(),
    AdminUserScreen(),
    AdminClassScreen(),
  ];

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: const Text('Sesi Anda akan berakhir.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              // Tutup dialog dulu
              Navigator.pop(context);
              // Logout — state di-reset, notifyListeners dipanggil di dalam logout()
              await context.read<AppProvider>().logout();
              if (!mounted) return;
              // Navigasi manual ke LoginScreen, hapus semua route
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected,
                minimumSize: const Size(80, 40)),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('LogAsdos Admin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: IndexedStack(index: _idx, children: _pages),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: BottomNavigationBar(
            currentIndex: _idx,
            onTap: (i) => setState(() => _idx = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  label: 'Pengguna'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.class_outlined),
                  label: 'Kelas'),
            ],
          ),
        ),
      );
}