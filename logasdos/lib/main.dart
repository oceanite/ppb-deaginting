import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'provider/app_provider.dart';
import 'ui/auth/login_screen.dart';
import 'ui/dosen/dosen_shell.dart';
import 'ui/admin/admin_shell.dart';
import 'ui/asdos/asdos_shell.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inisialisasi notifikasi sebelum app berjalan
  await NotificationService.instance.initialize();

  runApp(const LogAsdosApp());
}

class LogAsdosApp extends StatelessWidget {
  const LogAsdosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'LogAsdos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    // Minta izin notifikasi saat app pertama kali dibuka
    await NotificationService.instance.requestPermissions();

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      final fs = FirestoreService();
      final profile = await fs.getUser(fbUser.uid);
      if (profile != null && mounted) {
        final provider = context.read<AppProvider>();
        provider.setUserFromSession(profile);
        await provider.loadData();
      }
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<AppProvider>(
      builder: (_, prov, __) {
        if (!prov.isLoggedIn) return const LoginScreen();
        return switch (prov.currentUser!.role.name) {
          'asdos' => const AsdosShell(),
          'admin' => const AdminShell(),
          _       => const DosenShell(),
        };
      },
    );
  }
}