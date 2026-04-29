import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ActivityDetailDosenScreen extends StatefulWidget {
  final ActivityModel activity;
  const ActivityDetailDosenScreen(
      {super.key, required this.activity});

  @override
  State<ActivityDetailDosenScreen> createState() =>
      _ActivityDetailDosenScreenState();
}

class _ActivityDetailDosenScreenState
    extends State<ActivityDetailDosenScreen> {
  late ActivityModel _activity;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
  }

  // ── Approve ───────────────────────────────────────────────────────────────

  void _confirmApprove() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Setujui Aktivitas?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(
          'Aktivitas ${_activity.categoryLabel} dari '
          '${_activity.asdosName} akan disetujui.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(
                      color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _doApprove();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.approved,
                minimumSize: const Size(80, 40)),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  Future<void> _doApprove() async {
    setState(() => _processing = true);
    final err = await context
        .read<AppProvider>()
        .approveActivity(_activity.id);
    if (!mounted) return;
    setState(() {
      _processing = false;
      if (err == null) {
        _activity =
            _activity.copyWith(status: ActivityStatus.approved);
      }
    });
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.rejected));
    }
  }

  // ── Reject ────────────────────────────────────────────────────────────────

  void _confirmReject() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Aktivitas?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Aktivitas ${_activity.categoryLabel} dari '
            '${_activity.asdosName}.',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Alasan penolakan (opsional)...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal',
                  style: TextStyle(
                      color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              Navigator.pop(dialogCtx);
              _doReject(reason.isEmpty ? null : reason);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejected,
                minimumSize: const Size(80, 40)),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _doReject(String? reason) async {
    setState(() => _processing = true);
    final err = await context
        .read<AppProvider>()
        .rejectActivity(_activity.id, reason: reason);
    if (!mounted) return;
    setState(() {
      _processing = false;
      if (err == null) {
        _activity = _activity.copyWith(
            status: ActivityStatus.rejected,
            rejectReason: reason);
      }
    });
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.rejected));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final a = _activity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Detail Aktivitas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Asdos info
          Row(children: [
            AvatarCircle(
                initials: _initials(a.asdosName), size: 44),
            const SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.asdosName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  Text(a.className,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ]),
          ]),
          const SizedBox(height: 16),

          // Foto
          const Text('Bukti Foto',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          a.hasPhoto
              ? PhotoPreviewWidget(
                  photoPath: a.displayPhoto, height: 200)
              : Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border, width: 0.5),
                  ),
                  child: const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              size: 28,
                              color: AppColors.textTertiary),
                          SizedBox(height: 4),
                          Text('Tidak ada foto',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary)),
                        ]),
                  ),
                ),
          const SizedBox(height: 20),

          // Detail
          InfoCard(children: [
            DetailRow(
                label: 'Kategori',
                trailing: CategoryBadge(a.category)),
            const Divider(height: 20),
            DetailRow(
                label: 'Tanggal',
                value: formatDate(a.date, long: true)),
            const Divider(height: 20),
            DetailRow(label: 'Waktu', value: a.timeRange),
            const Divider(height: 20),
            DetailRow(
                label: 'Mode', trailing: ModeBadge(a.mode)),
            const Divider(height: 20),
            DetailRow(
                label: 'Status',
                trailing: StatusBadge(a.status)),
          ]),
          const SizedBox(height: 14),

          // Deskripsi
          InfoCard(children: [
            const Text('Deskripsi',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(a.description,
                style:
                    const TextStyle(fontSize: 14, height: 1.6)),
          ]),

          // Alasan reject
          if (a.status == ActivityStatus.rejected &&
              a.rejectReason != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.rejectedBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF7C1C1),
                    width: 0.5),
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.rejected),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Alasan Penolakan',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.rejected)),
                            const SizedBox(height: 4),
                            Text(a.rejectReason!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.rejected,
                                    height: 1.5)),
                          ]),
                    ),
                  ]),
            ),
          ],
          const SizedBox(height: 20),

          // Action buttons
          if (a.status == ActivityStatus.pending) ...[
            if (_processing)
              const Center(child: CircularProgressIndicator())
            else
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _confirmReject,
                    icon: const Icon(Icons.close_rounded,
                        size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rejected,
                      side: const BorderSide(
                          color: AppColors.rejected,
                          width: 0.5),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmApprove,
                    icon: const Icon(Icons.check_rounded,
                        size: 18),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.approved,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48)),
                  ),
                ),
              ]),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: a.status == ActivityStatus.approved
                    ? AppColors.approvedBg
                    : AppColors.rejectedBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(
                  a.status == ActivityStatus.approved
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: a.status == ActivityStatus.approved
                      ? AppColors.approved
                      : AppColors.rejected,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  a.status == ActivityStatus.approved
                      ? 'Aktivitas sudah disetujui.'
                      : 'Aktivitas sudah ditolak.',
                  style: TextStyle(
                    fontSize: 13,
                    color: a.status == ActivityStatus.approved
                        ? AppColors.approved
                        : AppColors.rejected,
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}