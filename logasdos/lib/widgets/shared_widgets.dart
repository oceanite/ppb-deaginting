import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── Status Badge ──────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final ActivityStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case ActivityStatus.pending:
        bg = AppColors.pendingBg;
        fg = AppColors.pendingColor;
        label = 'Pending';
      case ActivityStatus.approved:
        bg = AppColors.approvedBg;
        fg = AppColors.approved;
        label = 'Disetujui';
      case ActivityStatus.rejected:
        bg = AppColors.rejectedBg;
        fg = AppColors.rejected;
        label = 'Ditolak';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

// ── Category Badge ────────────────────────────────────────────────────────────

class CategoryBadge extends StatelessWidget {
  final ActivityCategory category;
  const CategoryBadge(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (category) {
      case ActivityCategory.mengajar:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryMid;
      case ActivityCategory.kuis:
        bg = AppColors.infoBg;
        fg = AppColors.info;
      case ActivityCategory.praktikum:
        bg = AppColors.tealBg;
        fg = AppColors.teal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        category == ActivityCategory.mengajar
            ? 'Mengajar'
            : category == ActivityCategory.kuis
                ? 'Kuis'
                : 'Praktikum',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}

// ── Mode Badge ────────────────────────────────────────────────────────────────

class ModeBadge extends StatelessWidget {
  final ClassMode mode;
  const ModeBadge(this.mode, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDaring = mode == ClassMode.daring;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isDaring ? AppColors.infoBg : AppColors.tealBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDaring ? 'Daring' : 'Luring',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDaring ? AppColors.info : AppColors.teal),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final Color bg;
  final Color fg;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.size = 40,
    this.bg = AppColors.primaryLight,
    this.fg = AppColors.primaryMid,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Center(
          child: Text(initials,
              style: TextStyle(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w500,
                  color: fg)),
        ),
      );
}

// ── Status Dot ────────────────────────────────────────────────────────────────

class StatusDot extends StatelessWidget {
  final ActivityStatus status;
  const StatusDot(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ActivityStatus.approved:
        color = AppColors.approved;
      case ActivityStatus.pending:
        color = AppColors.pendingIcon;
      case ActivityStatus.rejected:
        color = AppColors.rejected;
    }
    return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color? numberColor;

  const StatCard(
      {super.key,
      required this.number,
      required this.label,
      this.numberColor});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(number,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: numberColor ?? Colors.black87)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

// ── Section Header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(
      {super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryMid,
                      fontWeight: FontWeight.w500)),
            ),
        ],
      );
}

// ── Empty State ───────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState(
      {super.key,
      required this.message,
      this.icon = Icons.inbox_rounded});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
}

// ── Loading Overlay ───────────────────────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay(
      {super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          if (isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66FFFFFF),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      );
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    selected ? AppColors.primary : AppColors.border,
                width: 0.5),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary)),
        ),
      );
}

// ── Detail Row ────────────────────────────────────────────────────────────────

class DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;

  const DetailRow(
      {super.key, required this.label, this.value, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          trailing ??
              Text(value ?? '-',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      );
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class InfoCard extends StatelessWidget {
  final List<Widget> children;
  const InfoCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );
}

// ── Photo Preview ─────────────────────────────────────────────────────────────

class PhotoPreviewWidget extends StatelessWidget {
  final String? photoPath;
  final double height;
  final VoidCallback? onTap;

  const PhotoPreviewWidget(
      {super.key, this.photoPath, this.height = 160, this.onTap});

  bool get _isUrl =>
      photoPath != null && photoPath!.startsWith('http');
  bool get _hasPhoto =>
      photoPath != null && photoPath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hasPhoto
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _FullScreenPhoto(
                      path: photoPath!, isUrl: _isUrl),
                ),
              )
          : onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasPhoto ? AppColors.border : AppColors.primaryBorder,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _hasPhoto ? _buildImage() : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildImage() {
    final img = _isUrl
        ? Image.network(
            photoPath!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
            errorBuilder: (_, __, ___) => _buildErrorState(),
          )
        : Image.file(
            File(photoPath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildErrorState(),
          );

    return Stack(fit: StackFit.expand, children: [
      img,
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6)),
          child: const Text('Tap untuk perbesar',
              style: TextStyle(fontSize: 10, color: Colors.white)),
        ),
      ),
    ]);
  }

  Widget _buildPlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.camera_alt_rounded,
              size: 28, color: AppColors.primaryMid),
          SizedBox(height: 6),
          Text('Ambil foto / Pilih dari galeri',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          SizedBox(height: 2),
          Text('Tap untuk memilih',
              style: TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
        ],
      );

  Widget _buildErrorState() => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 28, color: AppColors.textTertiary),
          SizedBox(height: 6),
          Text('Foto tidak dapat ditampilkan',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textTertiary)),
        ],
      );
}

class _FullScreenPhoto extends StatelessWidget {
  final String path;
  final bool isUrl;
  const _FullScreenPhoto({required this.path, this.isUrl = false});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: isUrl
                ? Image.network(path, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64))
                : Image.file(File(path), fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64)),
          ),
        ),
      );
}

// ── Upload Progress Banner ────────────────────────────────────────────────────

class UploadProgressBanner extends StatelessWidget {
  final double progress;
  const UploadProgressBanner({super.key, required this.progress});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.primaryBorder, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primaryMid),
            ),
            const SizedBox(width: 8),
            const Text('Mengupload foto...',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryMid,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('${(progress * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primaryMid)),
          ]),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryBorder,
            color: AppColors.primaryMid,
            borderRadius: BorderRadius.circular(4),
          ),
        ]),
      );
}

// ── Formatted date ────────────────────────────────────────────────────────────

String formatDate(DateTime d, {bool long = false}) {
  const dShort = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  const dLong = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];
  const mShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  const mLong = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final idx = d.weekday % 7;
  if (long) {
    return '${dLong[idx]}, ${d.day} ${mLong[d.month - 1]} ${d.year}';
  }
  return '${dShort[idx]}, ${d.day} ${mShort[d.month - 1]} ${d.year}';
}