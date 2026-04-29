import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Dosen'),
            Tab(text: 'Asisten Dosen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _UserList(role: UserRole.dosen),
          _UserList(role: UserRole.asdos),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Tambah Pengguna',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const _CreateUserSheet(),
    );
  }
}

// ── User List per role ────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  final UserRole role;
  const _UserList({required this.role});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final list = role == UserRole.dosen ? prov.allDosen : prov.allAsdos;

      if (list.isEmpty) {
        return EmptyState(
          message: role == UserRole.dosen
              ? 'Belum ada dosen terdaftar'
              : 'Belum ada asisten dosen terdaftar',
          icon: Icons.people_outline_rounded,
        );
      }

      return RefreshIndicator(
        onRefresh: prov.loadData,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
              const Divider(indent: 72, height: 0),
          itemBuilder: (ctx2, i) => _UserTile(
            user: list[i],
            onTap: () => _showUserDetail(ctx2, list[i]),
          ),
        ),
      );
    });
  }

  void _showUserDetail(BuildContext context, UserModel user) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => AdminUserDetailScreen(user: user)));
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDosen = user.role == UserRole.dosen;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: AvatarCircle(
        initials: user.initials,
        size: 44,
        bg: isDosen ? AppColors.tealBg : AppColors.primaryLight,
        fg: isDosen ? AppColors.teal : AppColors.primaryMid,
      ),
      title: Text(user.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(user.email,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDosen ? AppColors.tealBg : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(isDosen ? 'Dosen' : 'Asdos',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDosen ? AppColors.teal : AppColors.primaryMid)),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded,
            size: 16, color: AppColors.textTertiary),
      ]),
      onTap: onTap,
    );
  }
}

// ── User Detail Screen ────────────────────────────────────────────────────────

class AdminUserDetailScreen extends StatefulWidget {
  final UserModel user;
  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late UserModel _user;
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nameCtrl = TextEditingController(text: _user.name);
    _selectedRole = _user.role;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final err = await context.read<AppProvider>().adminUpdateUser(
      _user.uid,
      name: _nameCtrl.text.trim(),
      role: _selectedRole,
    );
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
      return;
    }
    setState(() {
      _user = UserModel(
          uid: _user.uid,
          name: _nameCtrl.text.trim(),
          email: _user.email,
          role: _selectedRole);
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pengguna berhasil diperbarui.'),
            backgroundColor: AppColors.approved));
  }

  @override
  Widget build(BuildContext context) {
    final isDosen = _user.role == UserRole.dosen;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _editing = true),
            )
          else ...[
            TextButton(
              onPressed: () => setState(() { _editing = false; _nameCtrl.text = _user.name; _selectedRole = _user.role; }),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: _save,
              child: const Text('Simpan', style: TextStyle(color: AppColors.primaryMid, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Center(
            child: Column(children: [
              AvatarCircle(
                initials: _user.initials, size: 72,
                bg: isDosen ? AppColors.tealBg : AppColors.primaryLight,
                fg: isDosen ? AppColors.teal : AppColors.primaryMid,
              ),
              const SizedBox(height: 10),
              Text(_user.email,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 24),

          // Form / Info
          InfoCard(children: [
            // Nama
            const Text('Nama', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            _editing
                ? TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(hintText: 'Nama lengkap'),
                  )
                : Text(_user.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Divider(height: 24),

            // Email (tidak bisa diubah)
            const Text('Email', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(_user.email, style: const TextStyle(fontSize: 14)),
            const Divider(height: 24),

            // Role
            const Text('Role', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            _editing
                ? _RoleDropdown(
                    value: _selectedRole,
                    onChanged: (r) => setState(() => _selectedRole = r),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDosen ? AppColors.tealBg : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(isDosen ? 'Dosen' : 'Asisten Dosen',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDosen ? AppColors.teal : AppColors.primaryMid)),
                  ),
          ]),
          const SizedBox(height: 14),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pendingBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFAC775), width: 0.5),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.pendingColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Untuk reset password pengguna, gunakan fitur "Lupa Password" di halaman login atau minta pengguna melakukannya sendiri.',
                  style: TextStyle(fontSize: 12, color: AppColors.pendingColor, height: 1.4),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final UserRole value;
  final ValueChanged<UserRole> onChanged;
  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<UserRole>(
            value: value,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: UserRole.dosen, child: Text('Dosen')),
              DropdownMenuItem(value: UserRole.asdos, child: Text('Asisten Dosen')),
            ],
            onChanged: (r) { if (r != null) onChanged(r); },
          ),
        ),
      );
}

// ── Create User Bottom Sheet ──────────────────────────────────────────────────

class _CreateUserSheet extends StatefulWidget {
  const _CreateUserSheet();

  @override
  State<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends State<_CreateUserSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  UserRole _role = UserRole.asdos;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final err = await context.read<AppProvider>().adminCreateUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Akun ${_nameCtrl.text.trim()} berhasil dibuat.'),
      backgroundColor: AppColors.approved,
    ));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tambah Pengguna Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('Buat akun login untuk dosen atau asisten dosen.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 18),

              // Role selector
              const Text('Role', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(children: [
                _roleChip('Asisten Dosen', UserRole.asdos),
                const SizedBox(width: 10),
                _roleChip('Dosen', UserRole.dosen),
              ]),
              const SizedBox(height: 14),

              // Nama
              const Text('Nama Lengkap', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                ),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Nama minimal 3 karakter' : null,
              ),
              const SizedBox(height: 12),

              // Email
              const Text('Email Institusi', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: _role == UserRole.asdos
                      ? 'nim@student.univ.ac.id'
                      : 'nama@univ.ac.id',
                  prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textSecondary),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Password
              const Text('Password', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Buat Akun'),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      );

  Widget _roleChip(String label, UserRole role) {
    final sel = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: sel ? AppColors.primaryBorder : AppColors.border,
                width: sel ? 1 : 0.5),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: sel ? AppColors.primaryMid : AppColors.textSecondary)),
        ),
      ),
    );
  }
}