import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../asdos/asdos_home_screen.dart';
import '../dosen/dosen_shell.dart';
import '../admin/admin_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl= TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<AppProvider>();
    final err = await prov.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
      return;
    }
    final user = prov.currentUser!;
    Widget dest = switch (user.role) {
      UserRole.admin => const AdminShell(),
      UserRole.dosen => const DosenShell(),
      UserRole.asdos => const AsdosHomeScreen(),
    };
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => dest));
  }

  void _fillDemo(String email, String pass) {
    setState(() { _emailCtrl.text = email; _passCtrl.text = pass; });
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AppProvider, bool>((p) => p.loading);
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: loading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 48),

                // Logo
                Center(child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.menu_book_rounded, size: 32, color: AppColors.primaryMid),
                  ),
                  const SizedBox(height: 14),
                  const Text('LogAsdos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text('Digital Assistant Logbook', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ])),
                const SizedBox(height: 36),

                // Email
                const Text('Email', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan email',
                    prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 14),

                // Password
                const Text('Password', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18, color: AppColors.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPassword(context),
                    child: const Text('Lupa password?', style: TextStyle(fontSize: 12, color: AppColors.primaryMid)),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: loading ? null : _login, child: const Text('Masuk')),
                const SizedBox(height: 28),

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primaryMid),
                      SizedBox(width: 6),
                      Text('Akun disediakan oleh Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryMid)),
                    ]),
                    const SizedBox(height: 6),
                    const Text('Hubungi admin jika belum memiliki akun atau lupa password.',
                        style: TextStyle(fontSize: 11, color: AppColors.primaryMid, height: 1.4)),
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.primaryBorder, height: 1),
                    const SizedBox(height: 10),
                    const Text('Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryMid)),
                    const SizedBox(height: 6),
                    _DemoTile('Admin',    'admin@logasdos.id',         'admin123',  () => _fillDemo('admin@logasdos.id',         'admin123')),
                    const SizedBox(height: 4),
                    _DemoTile('Dosen',    'rina@univ.ac.id',           'dosen123',  () => _fillDemo('rina@univ.ac.id',           'dosen123')),
                    const SizedBox(height: 4),
                    _DemoTile('Asdos',    'budi@student.univ.ac.id',   'asdos123',  () => _fillDemo('budi@student.univ.ac.id',   'asdos123')),
                  ]),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Link reset password akan dikirim ke email kamu.',
              style: TextStyle(fontSize: 13, height: 1.5)),
          const SizedBox(height: 14),
          TextField(controller: ctrl, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'email@contoh.com')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final err = await context.read<AppProvider>().sendPasswordReset(ctrl.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(err ?? 'Link reset password telah dikirim.'),
                backgroundColor: err != null ? AppColors.rejected : AppColors.approved,
              ));
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  final String role, email, pass;
  final VoidCallback onTap;
  const _DemoTile(this.role, this.email, this.pass, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.primaryMid, borderRadius: BorderRadius.circular(4)),
        child: Text(role, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text('$email / $pass',
          style: const TextStyle(fontSize: 10, color: AppColors.primaryMid, fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis)),
      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryMid),
    ]),
  );
}