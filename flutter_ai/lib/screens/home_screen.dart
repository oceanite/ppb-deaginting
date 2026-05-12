// lib/screens/home_screen.dart
//
// Versi ini terhubung ke JournalNotifier (Riverpod).
// Tidak ada lagi data dummy — semua hasil datang dari AI pipeline sungguhan.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/empathy_map_data.dart';
import '../theme/app_theme.dart';
import '../state/journal_notifier.dart';
import '../widgets/recording_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/result_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<Color?> _bgAnimation;
  Color _lastBg = AppTheme.backgroundLight;
  SessionPhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bgAnimation = ColorTween(
      begin: AppTheme.backgroundLight,
      end: AppTheme.backgroundLight,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _transitionBackground(Color target) {
    final current = _bgAnimation.value ?? _lastBg;
    _lastBg = target;
    _bgAnimation = ColorTween(begin: current, end: target).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );
    _bgController.forward(from: 0);
  }

  // ── Callbacks ke JournalNotifier ──

  Future<void> _onStartRecording() async {
    final success =
        await ref.read(journalSessionProvider.notifier).startRecording();
    if (!success && mounted) {
      _showError(ref.read(journalSessionProvider).errorMessage ??
          'Gagal memulai rekaman');
    }
  }

  Future<void> _onFinishRecording() async {
    _transitionBackground(const Color(0xFFEAF0F2));
    await ref.read(journalSessionProvider.notifier).stopAndProcess();
  }

  void _onReset() {
    ref.read(journalSessionProvider.notifier).reset();
    _transitionBackground(AppTheme.backgroundLight);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB94040),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Sinkronisasi background dengan phase ──

  void _syncBackground(JournalSessionState session) {
    if (session.phase == _lastPhase) return;
    _lastPhase = session.phase;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (session.phase) {
        case SessionPhase.idle:
        case SessionPhase.recording:
          _transitionBackground(AppTheme.backgroundLight);
        case SessionPhase.processing:
          _transitionBackground(const Color(0xFFEAF0F2));
        case SessionPhase.done:
        case SessionPhase.error:
          break; // ditangani oleh _ResultLoader setelah data dimuat
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(journalSessionProvider);
    _syncBackground(session);

    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _bgAnimation.value ?? AppTheme.backgroundLight,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _buildCurrentView(session),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentView(JournalSessionState session) {
    switch (session.phase) {
      case SessionPhase.idle:
        return RecordingView(
          key: const ValueKey('home'),
          isRecording: false,
          onStartRecording: _onStartRecording,
          onFinishRecording: _onFinishRecording,
        );
      case SessionPhase.recording:
        return RecordingView(
          key: const ValueKey('recording'),
          isRecording: true,
          onStartRecording: _onStartRecording,
          onFinishRecording: _onFinishRecording,
        );
      case SessionPhase.processing:
        return const LoadingView(key: ValueKey('loading'));
      case SessionPhase.done:
        return _ResultLoader(
          key: ValueKey('result-${session.currentJournalId}'),
          journalId: session.currentJournalId!,
          onReset: _onReset,
          onBackgroundColor: _transitionBackground,
        );
      case SessionPhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          message: session.errorMessage ?? 'Terjadi kesalahan',
          onRetry: _onReset,
        );
    }
  }
}

// ─────────────────────────────────────────────
// _ResultLoader — memuat data nyata dari DB
// ─────────────────────────────────────────────

class _ResultLoader extends ConsumerWidget {
  final String journalId;
  final VoidCallback onReset;
  final void Function(Color) onBackgroundColor;

  const _ResultLoader({
    super.key,
    required this.journalId,
    required this.onReset,
    required this.onBackgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(_journalResultProvider(journalId));

    return resultAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => _ErrorView(message: 'Gagal memuat hasil: $e', onRetry: onReset),
      data: (data) {
        if (data == null) {
          return _ErrorView(message: 'Data tidak ditemukan', onRetry: onReset);
        }

        // Transisi background ke warna emosi hasil AI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final resultColor = Color.lerp(
            AppTheme.backgroundLight,
            data.colorHex,
            0.15,
          )!;
          onBackgroundColor(resultColor);
        });

        return ResultView(data: data, onReset: onReset);
      },
    );
  }
}

// Provider: fetch EmpathyMapData nyata dari DB berdasarkan journalId
final _journalResultProvider =
    FutureProvider.family<EmpathyMapData?, String>((ref, journalId) async {
  final repo = ref.read(journalRepositoryProvider);
  final entry = await repo.getById(journalId);
  if (entry?.empathyMap == null) return null;

  final em = entry!.empathyMap!;

  // Parse JSON string dari kolom map_json di SQLite
  final empathyMap = EmpathyMap.fromJsonString(em.mapJson);

  // Konversi hex string "#2C3E50" → Color(0xFF2C3E50)
  final colorInt =
      int.parse('FF${em.colorHex.replaceAll('#', '')}', radix: 16);

  return EmpathyMapData(
    dominantEmotion: em.dominantEmotion,
    colorHex: Color(colorInt),
    empathyMap: empathyMap,
  );
});

// ─────────────────────────────────────────────
// _ErrorView
// ─────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFB94040)),
            const SizedBox(height: 20),
            Text('Ada yang tidak beres',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}