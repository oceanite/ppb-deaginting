import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'activity_detail_dosen_screen.dart';

class DosenHomeScreen extends StatefulWidget {
  const DosenHomeScreen({super.key});

  @override
  State<DosenHomeScreen> createState() => _DosenHomeScreenState();
}

class _DosenHomeScreenState extends State<DosenHomeScreen> {
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
      final user        = prov.currentUser!;
      final asdosList   = prov.asdosList;
      final activities  = prov.activities;
      final pendingTotal =
          activities.where((a) => a.status == ActivityStatus.pending).length;
      final approvedTotal =
          activities.where((a) => a.status == ActivityStatus.approved).length;

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: prov.loadData,
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Header
                    Row(children: [
                      AvatarCircle(
                          initials: user.initials,
                          size: 44,
                          bg: AppColors.tealBg,
                          fg: AppColors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                              const Text('Dashboard Dosen',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ]),
                      ),
                      if (pendingTotal > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: AppColors.pendingBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                        color: AppColors.pendingIcon,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(
                                    '$pendingTotal perlu review',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.pendingColor)),
                              ]),
                        ),
                    ]),
                    const SizedBox(height: 16),

                    // Stats
                    Row(children: [
                      StatCard(
                          number: '${activities.length}',
                          label: 'Total Log'),
                      const SizedBox(width: 8),
                      StatCard(
                          number: '$pendingTotal',
                          label: 'Perlu Review',
                          numberColor: AppColors.pendingIcon),
                      const SizedBox(width: 8),
                      StatCard(
                          number: '$approvedTotal',
                          label: 'Disetujui',
                          numberColor: AppColors.approved),
                    ]),
                    const SizedBox(height: 20),

                    const SectionHeader(title: 'Asisten Dosen'),
                    const SizedBox(height: 10),
                  ]),
                ),
              ),

              prov.loading
                  ? const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator()))
                  : asdosList.isEmpty
                      ? const SliverFillRemaining(
                          child: EmptyState(
                              message:
                                  'Belum ada asisten terdaftar',
                              icon: Icons.people_outline_rounded))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx2, i) {
                              final asdos = asdosList[i];
                              final pCount = activities
                                  .where((a) =>
                                      a.asdosId == asdos.uid &&
                                      a.status ==
                                          ActivityStatus.pending)
                                  .length;
                              final tCount = activities
                                  .where((a) =>
                                      a.asdosId == asdos.uid)
                                  .length;
                              final colors = [
                                [AppColors.primaryLight, AppColors.primaryMid],
                                [AppColors.tealBg, AppColors.teal],
                                [AppColors.coralBg, AppColors.coral],
                                [AppColors.infoBg, AppColors.info],
                              ];
                              final c = colors[i % colors.length];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: _AsdosTile(
                                  asdos: asdos,
                                  pendingCount: pCount,
                                  totalCount: tCount,
                                  avatarBg: c[0],
                                  avatarFg: c[1],
                                  onTap: () => Navigator.push(
                                    ctx2,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          _AsdosActivitiesScreen(
                                              asdos: asdos),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: asdosList.length,
                          ),
                        ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 32)),
            ]),
          ),
        ),
      );
    });
  }
}

// ── Asdos Tile ────────────────────────────────────────────────────────────────

class _AsdosTile extends StatelessWidget {
  final UserModel asdos;
  final int pendingCount, totalCount;
  final Color avatarBg, avatarFg;
  final VoidCallback onTap;

  const _AsdosTile({
    required this.asdos,
    required this.pendingCount,
    required this.totalCount,
    required this.avatarBg,
    required this.avatarFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            AvatarCircle(
                initials: asdos.initials,
                size: 44,
                bg: avatarBg,
                fg: avatarFg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asdos.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('$totalCount aktivitas total',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ]),
            ),
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.pendingBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$pendingCount pending',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.pendingColor)),
              )
            else
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.approved),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textTertiary),
          ]),
        ),
      );
}

// ── Daftar aktivitas satu asdos (dipanggil dari tile) ────────────────────────

class _AsdosActivitiesScreen extends StatefulWidget {
  final UserModel asdos;
  const _AsdosActivitiesScreen({required this.asdos});

  @override
  State<_AsdosActivitiesScreen> createState() =>
      _AsdosActivitiesScreenState();
}

class _AsdosActivitiesScreenState
    extends State<_AsdosActivitiesScreen> {
  List<ActivityModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await context
        .read<AppProvider>()
        .getActivitiesForAsdos(widget.asdos.uid);
    if (mounted) setState(() { _list = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _list.where((a) => a.status == ActivityStatus.pending).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(widget.asdos.name,
              style: const TextStyle(fontSize: 15)),
          Text('$pending aktivitas pending',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400)),
        ]),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const EmptyState(
                  message: 'Belum ada aktivitas',
                  icon: Icons.receipt_long_rounded)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(indent: 72, height: 0),
                    itemBuilder: (ctx, i) {
                      final a = _list[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        leading: StatusDot(a.status),
                        title: Text(
                            '${a.categoryLabel} – ${a.className}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                            formatDate(a.date),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        trailing: StatusBadge(a.status),
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) =>
                                ActivityDetailDosenScreen(
                                    activity: a),
                          ),
                        ).then((_) => _load()),
                      );
                    },
                  ),
                ),
    );
  }
}