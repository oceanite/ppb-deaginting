import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../provider/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'input_activity_screen.dart';

// AsdosHomeScreen = hanya konten tab Beranda.
// Navbar diurus oleh AsdosShell — tidak ada Scaffold/navbar di sini.

class AsdosHomeScreen extends StatefulWidget {
  const AsdosHomeScreen({super.key});

  @override
  State<AsdosHomeScreen> createState() => _AsdosHomeScreenState();
}

class _AsdosHomeScreenState extends State<AsdosHomeScreen> {
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
      final user    = prov.currentUser!;
      final stats   = prov.stats;
      final classes = prov.classes;
      final pending = prov.activities
          .where((a) => a.status == ActivityStatus.pending)
          .length;

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
                          AvatarCircle(initials: user.initials, size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Halo, ${user.name.split(' ').first}! 👋',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  Text(_todayLabel(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ]),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Notif pending
                        if (pending > 0) ...[
                          _NotifBanner(count: pending),
                          const SizedBox(height: 14),
                        ],

                        // Stats
                        Row(children: [
                          StatCard(
                              number: '${stats.total}',
                              label: 'Total Log'),
                          const SizedBox(width: 8),
                          StatCard(
                              number: '${stats.approved}',
                              label: 'Disetujui',
                              numberColor: AppColors.approved),
                          const SizedBox(width: 8),
                          StatCard(
                              number: '${stats.pending}',
                              label: 'Pending',
                              numberColor: AppColors.pendingIcon),
                        ]),
                        const SizedBox(height: 20),

                        SectionHeader(title: 'Kelas yang Diampu'),
                        const SizedBox(height: 10),
                      ]),
                ),
              ),

              // Daftar kelas
              classes.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                          message: 'Belum ada kelas terdaftar',
                          icon: Icons.class_outlined))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx2, i) {
                          final c = classes[i];
                          final pCount = prov.activities
                              .where((a) =>
                                  a.classId == c.id &&
                                  a.status == ActivityStatus.pending)
                              .length;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: _ClassTile(
                              classModel: c,
                              pendingCount: pCount,
                              onTap: () => Navigator.push(
                                ctx2,
                                MaterialPageRoute(
                                  builder: (_) => InputActivityScreen(
                                      selectedClass: c),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: classes.length,
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: classes.isEmpty
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InputActivityScreen(
                          selectedClass: classes.first),
                    ),
                  ),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      );
    });
  }

  String _todayLabel() {
    const days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu',
      'Kamis', 'Jumat', 'Sabtu'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final now = DateTime.now();
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Banner pending ────────────────────────────────────────────────────────────

class _NotifBanner extends StatelessWidget {
  final int count;
  const _NotifBanner({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pendingBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFAC775), width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
                color: AppColors.pendingIcon,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.access_time_rounded,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aktivitas menunggu review',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.pendingColor)),
                  Text('$count log aktivitas belum disetujui dosen.',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFBA7517))),
                ]),
          ),
        ]),
      );
}

// ── Class tile ────────────────────────────────────────────────────────────────

class _ClassTile extends StatelessWidget {
  final ClassModel classModel;
  final int pendingCount;
  final VoidCallback onTap;

  const _ClassTile({
    required this.classModel,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: classModel.isOnline
                    ? AppColors.tealBg
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                classModel.isOnline
                    ? Icons.videocam_rounded
                    : Icons.school_rounded,
                size: 20,
                color: classModel.isOnline
                    ? AppColors.teal
                    : AppColors.primaryMid,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classModel.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                        '${classModel.startTime} – ${classModel.endTime} · ${classModel.room}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ]),
            ),
            const SizedBox(width: 8),
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
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
              ModeBadge(classModel.isOnline
                  ? ClassMode.daring
                  : ClassMode.luring),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textTertiary),
          ]),
        ),
      );
}