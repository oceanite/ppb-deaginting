import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class InputActivityScreen extends StatefulWidget {
  final ClassModel selectedClass;
  const InputActivityScreen({super.key, required this.selectedClass});

  @override
  State<InputActivityScreen> createState() => _InputActivityScreenState();
}

class _InputActivityScreenState extends State<InputActivityScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  // Simpan hanya id, bukan instance — hindari reference mismatch
  late String _selectedClassId;
  ActivityCategory _category = ActivityCategory.mengajar;
  ClassMode _mode = ClassMode.luring;
  File? _photoFile;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.selectedClass.id;
    _mode = widget.selectedClass.isOnline ? ClassMode.daring : ClassMode.luring;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Ambil ClassModel dari list provider berdasarkan id ────────────────────

  ClassModel _resolveClass(List<ClassModel> classes) {
    if (classes.isEmpty) return widget.selectedClass;
    try {
      return classes.firstWhere((c) => c.id == _selectedClassId);
    } catch (_) {
      // Fallback: kembalikan kelas pertama jika id tidak ditemukan
      return classes.first;
    }
  }

  // ── Photo sheet ───────────────────────────────────────────────────────────

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih sumber foto',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.primaryMid, size: 20),
                  ),
                  title: const Text('Kamera',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Ambil foto langsung',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () => _pick(ImageSource.camera),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.tealBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.teal, size: 20),
                  ),
                  title: const Text('Galeri',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Pilih dari foto tersimpan',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () => _pick(ImageSource.gallery),
                ),
                if (_photoFile != null) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.rejectedBg,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.rejected, size: 20),
                    ),
                    title: const Text('Hapus foto',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.rejected,
                            fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _photoFile = null);
                    },
                  ),
                ],
              ]),
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    Navigator.pop(context);
    final prov = context.read<AppProvider>();
    final file = source == ImageSource.camera
        ? await prov.pickImageFromCamera()
        : await prov.pickImageFromGallery();
    if (file != null) setState(() => _photoFile = file);
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final prov        = context.read<AppProvider>();
    final now         = DateTime.now();
    final activeClass = _resolveClass(prov.classes);

    final err = await prov.submitActivity(
      classId:   activeClass.id,
      className: activeClass.name,
      category:  _category,
      description: _descCtrl.text,
      mode: _mode,
      date: now,
      timeRange: '${activeClass.startTime} – ${activeClass.endTime}',
      photoFile: _photoFile,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(err),
            backgroundColor: AppColors.rejected),
      );
      return;
    }

    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: AppColors.approvedBg, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                size: 28, color: AppColors.approved),
          ),
          const SizedBox(height: 14),
          const Text('Laporan Terkirim!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text(
              'Log aktivitas berhasil disimpan dan menunggu persetujuan dosen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 44)),
            child: const Text('Oke'),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prov    = context.watch<AppProvider>();
    final classes = prov.classes;

    // Resolve instance yang valid dari list provider
    // Jika list masih kosong, gunakan widget.selectedClass sebagai fallback
    final activeClass = _resolveClass(classes);

    // Pastikan _selectedClassId tetap sinkron jika list baru ter-load
    if (classes.isNotEmpty && _selectedClassId != activeClass.id) {
      // Gunakan addPostFrameCallback agar tidak setState di tengah build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedClassId = activeClass.id);
      });
    }

    // Buat items dropdown — selalu pastikan widget.selectedClass ada di list
    // agar value tidak pernah orphan
    final dropdownItems = <ClassModel>[
      if (classes.isEmpty) widget.selectedClass,
      ...classes,
    ];

    // Pastikan tidak ada duplikat jika widget.selectedClass sudah ada di list
    final uniqueItems = dropdownItems
        .fold<Map<String, ClassModel>>({}, (map, c) {
          map[c.id] = c;
          return map;
        })
        .values
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Input Aktivitas')),
      body: LoadingOverlay(
        isLoading: _submitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // Upload progress
              if (prov.uploading) ...[
                UploadProgressBanner(progress: prov.uploadProgress),
                const SizedBox(height: 14),
              ],

              // ── Kelas ──────────────────────────────────────────────────

              const Text('Mata Kuliah',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    // Gunakan String id sebagai value — tidak pernah mismatch
                    value: _selectedClassId,
                    isExpanded: true,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87),
                    onChanged: (id) {
                      if (id == null) return;
                      final picked = uniqueItems.firstWhere(
                        (c) => c.id == id,
                        orElse: () => activeClass,
                      );
                      setState(() {
                        _selectedClassId = id;
                        _mode = picked.isOnline
                            ? ClassMode.daring
                            : ClassMode.luring;
                      });
                    },
                    items: uniqueItems
                        .map((c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(c.name,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Kategori ───────────────────────────────────────────────

              const Text('Kategori Aktivitas',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: ActivityCategory.values.map((cat) {
                  final sel = _category == cat;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(
                            right: cat != ActivityCategory.praktikum
                                ? 8
                                : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primaryLight
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: sel
                                  ? AppColors.primaryBorder
                                  : AppColors.border,
                              width: sel ? 1 : 0.5),
                        ),
                        child: Column(children: [
                          Icon(
                            cat == ActivityCategory.mengajar
                                ? Icons.cast_for_education_rounded
                                : cat == ActivityCategory.kuis
                                    ? Icons.quiz_rounded
                                    : Icons.science_rounded,
                            size: 22,
                            color: sel
                                ? AppColors.primaryMid
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat == ActivityCategory.mengajar
                                ? 'Mengajar'
                                : cat == ActivityCategory.kuis
                                    ? 'Kuis'
                                    : 'Praktikum',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: sel
                                    ? AppColors.primaryMid
                                    : AppColors.textSecondary),
                          ),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // ── Mode ───────────────────────────────────────────────────

              const Text('Mode Kelas',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: ClassMode.values.map((m) {
                    final sel = _mode == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mode = m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  m == ClassMode.luring
                                      ? Icons.location_on_outlined
                                      : Icons.videocam_outlined,
                                  size: 16,
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    m == ClassMode.luring
                                        ? 'Luring'
                                        : 'Daring (Zoom)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: sel
                                            ? Colors.white
                                            : AppColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // ── Deskripsi ──────────────────────────────────────────────

              const Text('Deskripsi Aktivitas',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Jelaskan aktivitas yang dilakukan...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Deskripsi tidak boleh kosong'
                        : null,
              ),
              const SizedBox(height: 18),

              // ── Foto ───────────────────────────────────────────────────

              const Text('Bukti Foto (Opsional)',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              _PhotoPickerWidget(
                  file: _photoFile, onTap: _showPhotoSheet),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('Kirim Laporan'),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Photo Picker Widget ───────────────────────────────────────────────────────

class _PhotoPickerWidget extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;
  const _PhotoPickerWidget({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Stack(children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.border, width: 0.5)),
            clipBehavior: Clip.antiAlias,
            child: Image.file(file!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded,
                        size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Ganti',
                        style: TextStyle(
                            fontSize: 11, color: Colors.white)),
                  ]),
            ),
          ),
        ),
        Positioned(
          bottom: 8, left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.approvedBg,
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: AppColors.approved, width: 0.5),
            ),
            child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 12, color: AppColors.approved),
                  SizedBox(width: 4),
                  Text('Foto terpilih',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.approved,
                          fontWeight: FontWeight.w500)),
                ]),
          ),
        ),
      ]);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.primaryBorder, width: 0.5),
        ),
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded,
                  size: 28, color: AppColors.primaryMid),
              SizedBox(height: 8),
              Text('Ambil foto / Pilih dari galeri',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 2),
              Text('Kamera · Galeri',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            ]),
      ),
    );
  }
}