import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ActivityDetailAsdosScreen extends StatelessWidget {
  final ActivityModel activity;
  const ActivityDetailAsdosScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Detail Aktivitas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Status banner
          _StatusBanner(
              status: activity.status,
              rejectReason: activity.rejectReason),
          const SizedBox(height: 20),

          // Foto
          const Text('Bukti Foto',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          activity.hasPhoto
              ? PhotoPreviewWidget(
                  photoPath: activity.displayPhoto, height: 180)
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
                label: 'Mata Kuliah',
                value: activity.className),
            const Divider(height: 20),
            DetailRow(
                label: 'Kategori',
                trailing: CategoryBadge(activity.category)),
            const Divider(height: 20),
            DetailRow(
                label: 'Tanggal',
                value: formatDate(activity.date, long: true)),
            const Divider(height: 20),
            DetailRow(label: 'Waktu', value: activity.timeRange),
            const Divider(height: 20),
            DetailRow(
                label: 'Mode',
                trailing: ModeBadge(activity.mode)),
            const Divider(height: 20),
            DetailRow(
                label: 'Status',
                trailing: StatusBadge(activity.status)),
          ]),
          const SizedBox(height: 14),

          // Deskripsi
          InfoCard(children: [
            const Text('Deskripsi Aktivitas',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(activity.description,
                style: const TextStyle(fontSize: 14, height: 1.6)),
          ]),

          // Alasan penolakan
          if (activity.status == ActivityStatus.rejected &&
              activity.rejectReason != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.rejectedBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF7C1C1), width: 0.5),
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.rejected),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alasan Penolakan',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.rejected)),
                            const SizedBox(height: 4),
                            Text(activity.rejectReason!,
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
        ]),
      ),
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final ActivityStatus status;
  final String? rejectReason;

  const _StatusBanner({required this.status, this.rejectReason});

  @override
  Widget build(BuildContext context) {
    Color bg, fg, border;
    IconData icon;
    String title, sub;

    switch (status) {
      case ActivityStatus.pending:
        bg = AppColors.pendingBg;
        fg = AppColors.pendingColor;
        border = const Color(0xFFFAC775);
        icon = Icons.hourglass_top_rounded;
        title = 'Menunggu Persetujuan';
        sub = 'Dosen belum meninjau laporan ini.';
      case ActivityStatus.approved:
        bg = AppColors.approvedBg;
        fg = AppColors.approved;
        border = const Color(0xFFC0DD97);
        icon = Icons.check_circle_rounded;
        title = 'Disetujui';
        sub = 'Laporan aktivitas kamu telah disetujui.';
      case ActivityStatus.rejected:
        bg = AppColors.rejectedBg;
        fg = AppColors.rejected;
        border = const Color(0xFFF7C1C1);
        icon = Icons.cancel_rounded;
        title = 'Ditolak';
        sub = rejectReason ?? 'Laporan ini tidak disetujui.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.5)),
      child: Row(children: [
        Icon(icon, size: 24, color: fg),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: fg)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        fontSize: 12,
                        color: fg.withOpacity(0.85))),
              ]),
        ),
      ]),
    );
  }
}