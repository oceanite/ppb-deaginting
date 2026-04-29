import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, prov, _) {
      final stats    = prov.adminStats;
      final activities = prov.activities;
      final recentActs = activities.take(5).toList();

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: prov.loadData,
            child: CustomScrollView(slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              size: 24, color: AppColors.primaryMid),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dashboard Admin',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500)),
                              Text('LogAsdos Management System',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Stats grid
                      if (stats != null) ...[
                        const Text('Ringkasan Sistem',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        _StatsGrid(stats: stats),
                        const SizedBox(height: 20),
                      ] else ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 20),
                      ],

                      // Activity status chart
                      if (activities.isNotEmpty) ...[
                        const SectionHeader(title: 'Status Aktivitas'),
                        const SizedBox(height: 12),
                        _ActivityStatusBar(activities: activities),
                        const SizedBox(height: 20),
                      ],

                      SectionHeader(
                        title: 'Aktivitas Terbaru',
                        action: activities.length > 5 ? 'Lihat semua' : null,
                        onAction: () {},
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Recent activities list
              recentActs.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                          message: 'Belum ada aktivitas',
                          icon: Icons.receipt_long_rounded))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx2, i) {
                          final a = recentActs[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _RecentActivityTile(activity: a),
                          );
                        },
                        childCount: recentActs.length,
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ]),
          ),
        ),
      );
    });
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final AdminStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Total Pengguna', '${stats.totalUsers}',
          Icons.people_rounded, AppColors.primaryMid, AppColors.primaryLight),
      _StatItem('Dosen', '${stats.totalDosen}',
          Icons.school_rounded, AppColors.teal, AppColors.tealBg),
      _StatItem('Asisten Dosen', '${stats.totalAsdos}',
          Icons.person_rounded, AppColors.info, AppColors.infoBg),
      _StatItem('Kelas Aktif', '${stats.totalClasses}',
          Icons.class_rounded, AppColors.coral, AppColors.coralBg),
      _StatItem('Total Log', '${stats.totalActivities}',
          Icons.receipt_long_rounded, AppColors.primaryMid, AppColors.primaryLight),
      _StatItem('Pending Review', '${stats.pendingActivities}',
          Icons.hourglass_top_rounded, AppColors.pendingColor, AppColors.pendingBg),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatCard(item: items[i]),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _StatItem(this.label, this.value, this.icon, this.color, this.bg);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(item.icon, size: 20, color: item.color),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: item.color)),
              Text(item.label,
                  style: TextStyle(
                      fontSize: 10,
                      color: item.color.withOpacity(0.8),
                      fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ]),
          ],
        ),
      );
}

// ── Activity Status Bar ───────────────────────────────────────────────────────

class _ActivityStatusBar extends StatelessWidget {
  final List<ActivityModel> activities;
  const _ActivityStatusBar({required this.activities});

  @override
  Widget build(BuildContext context) {
    final total    = activities.length;
    final approved = activities.where((a) => a.status == ActivityStatus.approved).length;
    final pending  = activities.where((a) => a.status == ActivityStatus.pending).length;
    final rejected = activities.where((a) => a.status == ActivityStatus.rejected).length;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(children: [
            if (approved > 0)
              Expanded(
                flex: approved,
                child: Container(height: 10, color: AppColors.approved),
              ),
            if (pending > 0)
              Expanded(
                flex: pending,
                child: Container(height: 10, color: AppColors.pendingIcon),
              ),
            if (rejected > 0)
              Expanded(
                flex: rejected,
                child: Container(height: 10, color: AppColors.rejected),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          _LegendDot(color: AppColors.approved,   label: 'Disetujui ($approved)'),
          const SizedBox(width: 16),
          _LegendDot(color: AppColors.pendingIcon, label: 'Pending ($pending)'),
          const SizedBox(width: 16),
          _LegendDot(color: AppColors.rejected,    label: 'Ditolak ($rejected)'),
        ]),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]);
}

// ── Recent Activity Tile ──────────────────────────────────────────────────────

class _RecentActivityTile extends StatelessWidget {
  final ActivityModel activity;
  const _RecentActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          StatusDot(activity.status),
          const SizedBox(width: 12),
          AvatarCircle(initials: _initials(activity.asdosName), size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.asdosName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${activity.categoryLabel} · ${activity.className}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(activity.status),
            const SizedBox(height: 3),
            Text(formatDate(activity.date),
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          ]),
        ]),
      );

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }
}