// lib/state/journal_notifier.dart
//
// JournalNotifier adalah "otak" aplikasi.
// Menggunakan Riverpod StateNotifier untuk mengelola state UI secara reaktif.
//
// Tambahkan ke pubspec.yaml:
//   dependencies:
//     flutter_riverpod: ^2.5.1
//     riverpod_annotation: ^2.3.5
//   dev_dependencies:
//     riverpod_generator: ^2.4.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/journal_repository.dart';
import '../services/recording_service.dart';
import '../services/ai_pipeline_service.dart';
import '../database/app_database.dart';

// ─────────────────────────────────────────────
// STATE MODEL
// ─────────────────────────────────────────────

enum SessionPhase { idle, recording, processing, done, error }

class JournalSessionState {
  final SessionPhase phase;
  final String? currentJournalId;
  final String? errorMessage;

  const JournalSessionState({
    this.phase = SessionPhase.idle,
    this.currentJournalId,
    this.errorMessage,
  });

  JournalSessionState copyWith({
    SessionPhase? phase,
    String? currentJournalId,
    String? errorMessage,
  }) =>
      JournalSessionState(
        phase: phase ?? this.phase,
        currentJournalId: currentJournalId ?? this.currentJournalId,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

// Singleton database
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Repository
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(appDatabaseProvider));
});

// Services
final recordingServiceProvider = Provider<RecordingService>((ref) {
  final service = RecordingService();
  ref.onDispose(service.dispose);
  return service;
});

final aiPipelineProvider = Provider<AiPipelineService>((ref) {
  return AiPipelineService();
});

// Stream semua jurnal (untuk halaman History)
final allJournalsProvider = StreamProvider<List<JournalWithEmpathyMap>>((ref) {
  return ref.watch(journalRepositoryProvider).watchAll();
});

// State sesi rekaman aktif
final journalSessionProvider =
    StateNotifierProvider<JournalNotifier, JournalSessionState>((ref) {
  return JournalNotifier(
    repository: ref.watch(journalRepositoryProvider),
    recording: ref.watch(recordingServiceProvider),
    ai: ref.watch(aiPipelineProvider),
  );
});

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class JournalNotifier extends StateNotifier<JournalSessionState> {
  final JournalRepository _repository;
  final RecordingService _recording;
  final AiPipelineService _ai;

  JournalNotifier({
    required JournalRepository repository,
    required RecordingService recording,
    required AiPipelineService ai,
  })  : _repository = repository,
        _recording = recording,
        _ai = ai,
        super(const JournalSessionState());

  // ── Step 1: Mulai merekam ──

  Future<bool> startRecording() async {
    // Cek izin dulu
    final hasPermission = await _recording.requestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        phase: SessionPhase.error,
        errorMessage: 'Izin mikrofon ditolak. Aktifkan di Pengaturan HP.',
      );
      return false;
    }

    try {
      await _recording.startRecording();
      state = state.copyWith(phase: SessionPhase.recording);
      return true;
    } catch (e) {
      state = state.copyWith(
        phase: SessionPhase.error,
        errorMessage: 'Gagal memulai rekaman: $e',
      );
      return false;
    }
  }

  // ── Step 2: Hentikan & proses ──

  Future<void> stopAndProcess() async {
    if (state.phase != SessionPhase.recording) return;

    RecordingResult? recordingResult;

    try {
      // Hentikan rekaman
      recordingResult = await _recording.stopRecording();

      // Simpan entri jurnal segera (pengguna bisa tutup app, data tidak hilang)
      final journalId = await _repository.createJournal(
        audioPath: recordingResult.path,
        durationSec: recordingResult.durationSec,
      );

      state = state.copyWith(
        phase: SessionPhase.processing,
        currentJournalId: journalId,
      );

      // Tandai sedang diproses
      await _repository.markProcessing(journalId);

      // Jalankan AI pipeline
      final result = await _ai.analyze(recordingResult.path);

      // Simpan hasil
      await _repository.saveResult(
        journalId: journalId,
        transcript: result.transcript,
        result: result.empathyMapData,
      );

      state = state.copyWith(phase: SessionPhase.done);
    } on AiPipelineException catch (e) {
      // Error dari AI — jurnal tetap tersimpan, bisa di-retry nanti
      if (state.currentJournalId != null) {
        await _repository.markError(state.currentJournalId!);
      }
      state = state.copyWith(
        phase: SessionPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      if (state.currentJournalId != null) {
        await _repository.markError(state.currentJournalId!);
      }
      state = state.copyWith(
        phase: SessionPhase.error,
        errorMessage: 'Terjadi kesalahan tidak terduga: $e',
      );
    }
  }

  // ── Cancel ──

  Future<void> cancelRecording() async {
    await _recording.cancelRecording();
    state = const JournalSessionState();
  }

  // ── Reset ke idle ──

  void reset() {
    state = const JournalSessionState();
  }

  // ── Delete ──

  Future<void> deleteJournal(String journalId) async {
    await _repository.deleteJournal(journalId);
  }

  // ── Amplitude stream untuk animasi ──

  Stream<double> get amplitudeStream => _recording.amplitudeStream;
}