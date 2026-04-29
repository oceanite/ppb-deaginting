import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'activity_detail_asdos_screen.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() =>
      _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  ActivityStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final filtered = prov.filterActivities(_filter);

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Riwayat Aktivitas')),
        body: Column(children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              AppFilterChip(
                  label: 'Semua',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null)),
              const SizedBox(width: 8),
              AppFilterChip(
                  label: 'Pending',
                  selected: _filter == ActivityStatus.pending,
                  onTap: () => setState(
                      () => _filter = ActivityStatus.pending)),
              const SizedBox(width: 8),
              AppFilterChip(
                  label: 'Disetujui',
                  selected: _filter == ActivityStatus.approved,
                  onTap: () => setState(
                      () => _filter = ActivityStatus.approved)),
              const SizedBox(width: 8),
              AppFilterChip(
                  label: 'Ditolak',
                  selected: _filter == ActivityStatus.rejected,
                  onTap: () => setState(
                      () => _filter = ActivityStatus.rejected)),
            ]),
          ),
          const Divider(height: 0),

          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    message: 'Belum ada aktivitas',
                    icon: Icons.receipt_long_rounded)
                : RefreshIndicator(
                    onRefresh: prov.loadData,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(indent: 72, height: 0),
                      itemBuilder: (ctx2, i) => _ActivityTile(
                        activity: filtered[i],
                        onTap: () => Navigator.push(
                          ctx2,
                          MaterialPageRoute(
                            builder: (_) => ActivityDetailAsdosScreen(
                                activity: filtered[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ]),
      );
    });
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;

  const _ActivityTile({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            Column(children: [
              StatusDot(activity.status),
              Container(
                  width: 1, height: 32, color: AppColors.border),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      CategoryBadge(activity.category),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(activity.className,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(formatDate(activity.date),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary)),
                  ]),
            ),
            const SizedBox(width: 8),
            StatusBadge(activity.status),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textTertiary),
          ]),
        ),
      );
}