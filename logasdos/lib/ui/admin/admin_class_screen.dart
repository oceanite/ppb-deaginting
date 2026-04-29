import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ── Shared time picker helper ─────────────────────────────────────────────────

/// Buka Material TimePicker dan kembalikan string "HH:mm".
/// [initial] : string "HH:mm" yang jadi nilai awal picker.
Future<String?> pickTime(BuildContext context, {String initial = '08:00'}) async {
  final parts = initial.split(':');
  final initTod = TimeOfDay(
    hour:   int.tryParse(parts.isNotEmpty ? parts[0] : '8')  ?? 8,
    minute: int.tryParse(parts.length > 1  ? parts[1] : '0') ?? 0,
  );
  final picked = await showTimePicker(
    context: context,
    initialTime: initTod,
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (picked == null) return null;
  final h = picked.hour.toString().padLeft(2, '0');
  final m = picked.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Widget tombol yang menampilkan jam dan membuka TimePicker saat ditap.
class TimePickerButton extends StatelessWidget {
  final String label;
  final String value;         // "HH:mm"
  final ValueChanged<String> onChanged;

  const TimePickerButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final picked = await pickTime(context, initial: value);
          if (picked != null) onChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(children: [
            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primaryMid),
            const SizedBox(width: 10),
            Text(value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
            const Spacer(),
            const Text('Ubah', style: TextStyle(fontSize: 12, color: AppColors.primaryMid)),
          ]),
        ),
      ),
    ]);
  }
}

// ── DropdownField helper ──────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Main Screen
// ══════════════════════════════════════════════════════════════════════════════

class AdminClassScreen extends StatelessWidget {
  const AdminClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final classes = prov.classes;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Manajemen Kelas')),
        body: classes.isEmpty
            ? const EmptyState(
                message: 'Belum ada kelas terdaftar',
                icon: Icons.class_outlined)
            : RefreshIndicator(
                onRefresh: prov.loadData,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: classes.length,
                  separatorBuilder: (_, __) =>
                      const Divider(indent: 72, height: 0),
                  itemBuilder: (ctx2, i) => _ClassTile(
                    classModel: classes[i],
                    onTap: () => Navigator.push(
                      ctx2,
                      MaterialPageRoute(
                          builder: (_) =>
                              AdminClassDetailScreen(classModel: classes[i])),
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => const _CreateClassSheet(),
          ),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Tambah Kelas',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
      );
    });
  }
}

// ── Class Tile ────────────────────────────────────────────────────────────────

class _ClassTile extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;
  const _ClassTile({required this.classModel, required this.onTap});

  static const _days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: classModel.isOnline ? AppColors.tealBg : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            classModel.isOnline ? Icons.videocam_rounded : Icons.school_rounded,
            size: 20,
            color: classModel.isOnline ? AppColors.teal : AppColors.primaryMid,
          ),
        ),
        title: Text(classModel.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 2),
          Text(classModel.dosenName,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(
              '${_days[classModel.dayOfWeek.clamp(1, 7)]}  ${classModel.startTime}–${classModel.endTime}  ·  ${classModel.room}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Text('${classModel.asdosIds.length} asdos',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryMid,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: AppColors.textTertiary),
        ]),
        onTap: onTap,
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Detail Screen
// ══════════════════════════════════════════════════════════════════════════════

class AdminClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;
  const AdminClassDetailScreen({super.key, required this.classModel});

  @override
  State<AdminClassDetailScreen> createState() =>
      _AdminClassDetailScreenState();
}

class _AdminClassDetailScreenState extends State<AdminClassDetailScreen> {
  late ClassModel _class;

  static const _days = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _class = widget.classModel;
  }

  void _refreshClass() {
    final updated = context
        .read<AppProvider>()
        .classes
        .firstWhere((c) => c.id == _class.id, orElse: () => _class);
    setState(() => _class = updated);
  }

  Future<void> _removeAsdos(UserModel asdos) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Asdos?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text('Hapus ${asdos.name} dari kelas ${_class.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected,
                minimumSize: const Size(80, 40)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final err = await context
        .read<AppProvider>()
        .adminRemoveAsdos(_class.id, asdos.uid);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
    } else {
      _refreshClass();
    }
  }

  Future<void> _deleteClass() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kelas?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content:
            Text('Kelas "${_class.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected,
                minimumSize: const Size(80, 40)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final err =
        await context.read<AppProvider>().adminDeleteClass(_class.id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov         = context.watch<AppProvider>();
    final allAsdos     = prov.allAsdos;
    final assignedIds  = _class.asdosIds;
    final assigned     = allAsdos.where((u) => assignedIds.contains(u.uid)).toList();
    final unassigned   = allAsdos.where((u) => !assignedIds.contains(u.uid)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Kelas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit kelas',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => _EditClassSheet(
                  classModel: _class, onSaved: _refreshClass),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.rejected),
            tooltip: 'Hapus kelas',
            onPressed: _deleteClass,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Info kelas
          InfoCard(children: [
            DetailRow(label: 'Nama Kelas', value: _class.name),
            const Divider(height: 20),
            DetailRow(label: 'Dosen Pengampu', value: _class.dosenName),
            const Divider(height: 20),
            DetailRow(
                label: 'Jadwal',
                value:
                    '${_days[_class.dayOfWeek.clamp(1, 7)]}, ${_class.startTime} – ${_class.endTime}'),
            const Divider(height: 20),
            DetailRow(label: 'Ruang', value: _class.room),
            const Divider(height: 20),
            DetailRow(
                label: 'Mode',
                trailing: ModeBadge(
                    _class.isOnline ? ClassMode.daring : ClassMode.luring)),
          ]),
          const SizedBox(height: 20),

          // Asdos
          SectionHeader(
            title: 'Asisten Dosen (${assigned.length})',
            action: unassigned.isNotEmpty ? '+ Assign Asdos' : null,
            onAction: () => _showAssignSheet(context, unassigned),
          ),
          const SizedBox(height: 10),

          assigned.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: const Center(
                    child: Text('Belum ada asdos yang ditugaskan.',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assigned.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) {
                    final a = assigned[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          AvatarCircle(initials: a.initials, size: 40),
                      title: Text(a.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(a.email,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                      trailing: IconButton(
                        icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.rejected,
                            size: 20),
                        onPressed: () => _removeAsdos(a),
                      ),
                    );
                  },
                ),
        ]),
      ),
    );
  }

  void _showAssignSheet(BuildContext context, List<UserModel> unassigned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AssignAsdosSheet(
        classId: _class.id,
        unassigned: unassigned,
        onAssigned: _refreshClass,
      ),
    );
  }
}

// ── Assign Asdos Sheet ────────────────────────────────────────────────────────

class _AssignAsdosSheet extends StatefulWidget {
  final String classId;
  final List<UserModel> unassigned;
  final VoidCallback onAssigned;

  const _AssignAsdosSheet({
    required this.classId,
    required this.unassigned,
    required this.onAssigned,
  });

  @override
  State<_AssignAsdosSheet> createState() => _AssignAsdosSheetState();
}

class _AssignAsdosSheetState extends State<_AssignAsdosSheet> {
  UserModel? _selected;
  bool _loading = false;

  Future<void> _assign() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    final err = await context
        .read<AppProvider>()
        .adminAssignAsdos(widget.classId, _selected!.uid);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
      return;
    }
    widget.onAssigned();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_selected!.name} berhasil ditugaskan.'),
      backgroundColor: AppColors.approved,
    ));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('Assign Asisten Dosen',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 14),
            _DropdownField<UserModel?>(
              label: 'Pilih Asisten Dosen',
              value: _selected,
              items: [
                const DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih asdos --',
                        style:
                            TextStyle(color: AppColors.textTertiary))),
                ...widget.unassigned.map((u) =>
                    DropdownMenuItem(value: u, child: Text(u.name))),
              ],
              onChanged: (u) => setState(() => _selected = u),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_selected == null || _loading) ? null : _assign,
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Tugaskan'),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Create Class Sheet  —  semua input waktu pakai TimePicker
// ══════════════════════════════════════════════════════════════════════════════

class _CreateClassSheet extends StatefulWidget {
  const _CreateClassSheet();

  @override
  State<_CreateClassSheet> createState() => _CreateClassSheetState();
}

class _CreateClassSheetState extends State<_CreateClassSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _roomCtrl  = TextEditingController();

  UserModel? _selectedDosen;
  int    _dayOfWeek = 1;
  String _startTime = '08:00';
  String _endTime   = '09:40';
  bool   _isOnline  = false;
  bool   _loading   = false;

  static const _dayItems = [
    DropdownMenuItem(value: 1, child: Text('Senin')),
    DropdownMenuItem(value: 2, child: Text('Selasa')),
    DropdownMenuItem(value: 3, child: Text('Rabu')),
    DropdownMenuItem(value: 4, child: Text('Kamis')),
    DropdownMenuItem(value: 5, child: Text('Jumat')),
    DropdownMenuItem(value: 6, child: Text('Sabtu')),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDosen == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih dosen pengampu terlebih dahulu.')));
      return;
    }
    setState(() => _loading = true);
    final err = await context.read<AppProvider>().adminCreateClass(
      name: _nameCtrl.text.trim(),
      dosenId: _selectedDosen!.uid,
      dosenName: _selectedDosen!.name,
      startTime: _startTime,
      endTime: _endTime,
      room: _isOnline ? 'Online' : _roomCtrl.text.trim(),
      isOnline: _isOnline,
      dayOfWeek: _dayOfWeek,
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
      content: Text('Kelas "${_nameCtrl.text.trim()}" berhasil dibuat.'),
      backgroundColor: AppColors.approved,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final allDosen = context.watch<AppProvider>().allDosen;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Tambah Kelas Baru',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 18),

              // Nama
              const Text('Nama Mata Kuliah',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'contoh: Algoritma & Pemrograman'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama kelas wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              // Dosen
              _DropdownField<UserModel?>(
                label: 'Dosen Pengampu',
                value: _selectedDosen,
                items: [
                  const DropdownMenuItem(
                      value: null,
                      child: Text('-- Pilih dosen --',
                          style:
                              TextStyle(color: AppColors.textTertiary))),
                  ...allDosen.map((d) =>
                      DropdownMenuItem(value: d, child: Text(d.name))),
                ],
                onChanged: (d) => setState(() => _selectedDosen = d),
              ),
              const SizedBox(height: 14),

              // Hari
              _DropdownField<int>(
                label: 'Hari',
                value: _dayOfWeek,
                items: _dayItems,
                onChanged: (d) => setState(() => _dayOfWeek = d!),
              ),
              const SizedBox(height: 14),

              // Waktu — TimePicker
              Row(children: [
                Expanded(
                  child: TimePickerButton(
                    label: 'Jam Mulai',
                    value: _startTime,
                    onChanged: (t) => setState(() => _startTime = t),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimePickerButton(
                    label: 'Jam Selesai',
                    value: _endTime,
                    onChanged: (t) => setState(() => _endTime = t),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Mode
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  const Text('Kelas Daring (Zoom/Online)',
                      style: TextStyle(fontSize: 13)),
                  Switch(
                    value: _isOnline,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isOnline = v),
                  ),
                ]),
              ),

              // Ruang (jika luring)
              if (!_isOnline) ...[
                const SizedBox(height: 14),
                const Text('Ruang',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _roomCtrl,
                  decoration: const InputDecoration(
                      hintText: 'contoh: Gedung A / 201'),
                  validator: (v) =>
                      (!_isOnline && (v == null || v.trim().isEmpty))
                          ? 'Ruang wajib diisi'
                          : null,
                ),
              ],
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Buat Kelas'),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Edit Class Sheet  —  juga pakai TimePicker
// ══════════════════════════════════════════════════════════════════════════════

class _EditClassSheet extends StatefulWidget {
  final ClassModel classModel;
  final VoidCallback onSaved;
  const _EditClassSheet({required this.classModel, required this.onSaved});

  @override
  State<_EditClassSheet> createState() => _EditClassSheetState();
}

class _EditClassSheetState extends State<_EditClassSheet> {
  final _formKey  = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _roomCtrl;
  late String _startTime;
  late String _endTime;
  late int    _dayOfWeek;
  late bool   _isOnline;
  UserModel?  _selectedDosen;
  bool _loading = false;

  static const _dayItems = [
    DropdownMenuItem(value: 1, child: Text('Senin')),
    DropdownMenuItem(value: 2, child: Text('Selasa')),
    DropdownMenuItem(value: 3, child: Text('Rabu')),
    DropdownMenuItem(value: 4, child: Text('Kamis')),
    DropdownMenuItem(value: 5, child: Text('Jumat')),
    DropdownMenuItem(value: 6, child: Text('Sabtu')),
  ];

  @override
  void initState() {
    super.initState();
    final c    = widget.classModel;
    _nameCtrl  = TextEditingController(text: c.name);
    _roomCtrl  = TextEditingController(text: c.isOnline ? '' : c.room);
    _startTime = c.startTime;
    _endTime   = c.endTime;
    _dayOfWeek = c.dayOfWeek;
    _isOnline  = c.isOnline;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final dosenId   = _selectedDosen?.uid   ?? widget.classModel.dosenId;
    final dosenName = _selectedDosen?.name  ?? widget.classModel.dosenName;

    final updated = widget.classModel.copyWith(
      name:      _nameCtrl.text.trim(),
      dosenId:   dosenId,
      dosenName: dosenName,
      startTime: _startTime,
      endTime:   _endTime,
      room:      _isOnline ? 'Online' : _roomCtrl.text.trim(),
      isOnline:  _isOnline,
      dayOfWeek: _dayOfWeek,
    );

    final err = await context.read<AppProvider>().adminUpdateClass(updated);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.rejected));
      return;
    }
    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allDosen = context.watch<AppProvider>().allDosen;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Edit Kelas',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 18),

              // Nama
              const Text('Nama Mata Kuliah',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'Nama mata kuliah'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              // Dosen
              _DropdownField<UserModel?>(
                label: 'Dosen Pengampu',
                value: _selectedDosen,
                items: [
                  DropdownMenuItem(
                      value: null,
                      child: Text(
                          'Tetap: ${widget.classModel.dosenName}',
                          style: const TextStyle(
                              color: AppColors.textSecondary))),
                  ...allDosen.map((d) =>
                      DropdownMenuItem(value: d, child: Text(d.name))),
                ],
                onChanged: (d) => setState(() => _selectedDosen = d),
              ),
              const SizedBox(height: 14),

              // Hari
              _DropdownField<int>(
                label: 'Hari',
                value: _dayOfWeek,
                items: _dayItems,
                onChanged: (d) => setState(() => _dayOfWeek = d!),
              ),
              const SizedBox(height: 14),

              // Waktu — TimePicker
              Row(children: [
                Expanded(
                  child: TimePickerButton(
                    label: 'Jam Mulai',
                    value: _startTime,
                    onChanged: (t) => setState(() => _startTime = t),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimePickerButton(
                    label: 'Jam Selesai',
                    value: _endTime,
                    onChanged: (t) => setState(() => _endTime = t),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Mode
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  const Text('Kelas Daring (Zoom/Online)',
                      style: TextStyle(fontSize: 13)),
                  Switch(
                    value: _isOnline,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isOnline = v),
                  ),
                ]),
              ),

              if (!_isOnline) ...[
                const SizedBox(height: 14),
                const Text('Ruang',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _roomCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Gedung / Ruang'),
                  validator: (v) =>
                      (!_isOnline && (v == null || v.trim().isEmpty))
                          ? 'Wajib diisi'
                          : null,
                ),
              ],
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan Perubahan'),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
      ),
    );
  }
}
