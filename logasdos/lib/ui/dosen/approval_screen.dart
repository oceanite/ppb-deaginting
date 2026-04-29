import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'activity_detail_dosen_screen.dart';

/// Tab Review di shell dosen — tampilkan semua pending,
/// dukung bulk select + approve/reject.
class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final Set<String> _selected = {};
  bool _selectMode = false;

  List<ActivityModel> get _pending =>
      context.read<AppProvider>().activities
          .where((a) => a.status == ActivityStatus.pending)
          .toList();

  bool get _allSelected =>
      _pending.isNotEmpty &&
      _pending.every((a) => _selected.contains(a.id));

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selected.clear();
    });
  }

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selected.removeAll(_pending.map((a) => a.id));
      } else {
        _selected.addAll(_pending.map((a) => a.id));
      }
    });
  }

  void _toggle(String id) {
    setState(() =>
        _selected.contains(id) ? _selected.remove(id) : _selected.add(id));
  }

  void _bulkAction(bool approve, AppProvider prov) {
    if (_selected.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
            approve
                ? 'Konfirmasi Persetujuan'
                : 'Konfirmasi Penolakan',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),
        content: Text(
          'Anda akan ${approve ? "menyetujui" : "menolak"} '
          '${_selected.length} aktivitas. '
          'Tindakan ini tidak dapat dibatalkan.',
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
              _execute(approve, prov);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  approve ? AppColors.approved : AppColors.rejected,
              minimumSize: const Size(80, 40),
            ),
            child: Text(approve ? 'Ya, Setujui' : 'Ya, Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> _execute(bool approve, AppProvider prov) async {
    final ids = _selected.toList();
    final err = approve
        ? await prov.bulkApprove(ids)
        : await prov.bulkReject(ids);

    if (!mounted) return;
    setState(() {
      _selected.clear();
      _selectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ??
          '${ids.length} aktivitas berhasil ${approve ? "disetujui" : "ditolak"}.'),
      backgroundColor:
          err != null ? AppColors.rejected : AppColors.approved,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final pending = prov.activities
          .where((a) => a.status == ActivityStatus.pending)
          .toList();

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              'Perlu Direview${pending.isNotEmpty ? " (${pending.length})" : ""}'),
          actions: [
            if (pending.isNotEmpty)
              TextButton(
                onPressed: _toggleSelectMode,
                child: Text(
                    _selectMode ? 'Batal' : 'Pilih',
                    style: const TextStyle(
                        color: AppColors.primaryMid,
                        fontWeight: FontWeight.w500)),
              ),
            if (_selectMode && pending.isNotEmpty)
              TextButton(
                onPressed: _toggleAll,
                child: Text(
                    _allSelected ? 'Batal Semua' : 'Pilih Semua',
                    style: const TextStyle(
                        color: AppColors.primaryMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        body: Stack(children: [
          pending.isEmpty
              ? const EmptyState(
                  message:
                      'Tidak ada aktivitas yang perlu direview',
                  icon: Icons.check_circle_outline_rounded)
              : RefreshIndicator(
                  onRefresh: prov.loadData,
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                        bottom: _selected.isNotEmpty ? 80 : 16),
                    itemCount: pending.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0, indent: 72),
                    itemBuilder: (ctx2, i) {
                      final a = pending[i];
                      final isSel = _selected.contains(a.id);
                      return InkWell(
                        onTap: () => _selectMode
                            ? _toggle(a.id)
                            : Navigator.push(
                                ctx2,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ActivityDetailDosenScreen(
                                          activity: a),
                                ),
                              ).then((_) => prov.loadData()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(children: [
                            SizedBox(
                              width: 28,
                              child: _selectMode
                                  ? Checkbox(
                                      value: isSel,
                                      onChanged: (_) =>
                                          _toggle(a.id),
                                      visualDensity:
                                          VisualDensity.compact)
                                  : AvatarCircle(
                                      initials: _initials(
                                          a.asdosName),
                                      size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      CategoryBadge(a.category),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(a.className,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .textSecondary),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis),
                                      ),
                                    ]),
                                    const SizedBox(height: 3),
                                    Text(
                                        '${a.asdosName} · ${formatDate(a.date)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors
                                                .textSecondary)),
                                  ]),
                            ),
                            if (!_selectMode) ...[
                              const StatusBadge(ActivityStatus.pending),
                              const SizedBox(width: 4),
                              const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: AppColors.textTertiary),
                            ],
                          ]),
                        ),
                      );
                    },
                  ),
                ),

          // Bulk action bar
          if (_selected.isNotEmpty)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: AppColors.border,
                                width: 0.5))),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text('${_selected.length}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryMid)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('dipilih',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ),
                      OutlinedButton(
                        onPressed: () => _bulkAction(false, prov),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rejected,
                          side: const BorderSide(
                              color: AppColors.rejected,
                              width: 0.5),
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                        ),
                        child: const Text('Tolak',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _bulkAction(true, prov),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.approved,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 40),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                        ),
                        child: const Text('Setujui',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      );
    });
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}