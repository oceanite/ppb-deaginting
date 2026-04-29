import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../auth/login_screen.dart';

class DosenProfile extends StatelessWidget {
  const DosenProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(
          child: Column(children: [
            AvatarCircle(
                initials: user.initials,
                size: 72,
                bg: AppColors.tealBg,
                fg: AppColors.teal),
            const SizedBox(height: 12),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(user.email,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.tealBg,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Dosen',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal)),
            ),
          ]),
        ),
        const SizedBox(height: 28),

        _item(Icons.lock_outline_rounded, 'Ganti Password',
            () => _showChangePassword(context)),
        _item(Icons.bar_chart_rounded, 'Laporan & Statistik', () {}),
        _item(Icons.help_outline_rounded, 'Bantuan & FAQ', () {}),
        const Divider(height: 28),
        _item(Icons.logout_rounded, 'Keluar',
            () => _logout(context), color: AppColors.rejected),
      ]),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? Colors.black87;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Icon(icon, size: 20, color: c),
      title: Text(label, style: TextStyle(fontSize: 14, color: c)),
      trailing: color == null
          ? const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textTertiary)
          : null,
      onTap: onTap,
    );
  }

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),
        content: const Text('Sesi Anda akan berakhir.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
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
}

// ── Change Password Sheet ─────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _cfmCtrl = TextEditingController();
  bool _o1 = true, _o2 = true, _o3 = true, _loading = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _cfmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await context
        .read<AppProvider>()
        .changePassword(_oldCtrl.text, _newCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.rejected));
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password berhasil diubah.'),
        backgroundColor: AppColors.approved));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Ganti Password',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              _pf('Password Lama', _oldCtrl, _o1,
                  () => setState(() => _o1 = !_o1),
                  (v) => (v == null || v.isEmpty)
                      ? 'Wajib diisi'
                      : null),
              const SizedBox(height: 12),
              _pf('Password Baru', _newCtrl, _o2,
                  () => setState(() => _o2 = !_o2),
                  (v) => (v == null || v.length < 6)
                      ? 'Minimal 6 karakter'
                      : null),
              const SizedBox(height: 12),
              _pf('Konfirmasi Password Baru', _cfmCtrl, _o3,
                  () => setState(() => _o3 = !_o3),
                  (v) => v != _newCtrl.text
                      ? 'Password tidak cocok'
                      : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white))
                    : const Text('Simpan Password'),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      );

  Widget _pf(
    String label,
    TextEditingController ctrl,
    bool obs,
    VoidCallback toggle,
    String? Function(String?) validator,
  ) =>
      TextFormField(
        controller: ctrl,
        obscureText: obs,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(
                obs
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary),
            onPressed: toggle,
          ),
        ),
        validator: validator,
      );
}