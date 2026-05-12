// lib/services/recording_service.dart
//
// Mengelola siklus hidup rekaman audio.
// Menyimpan file ke documents directory dengan nama berbasis timestamp.
//
// Tambahkan ke pubspec.yaml:
//   dependencies:
//     flutter_sound: ^9.2.13
//     permission_handler: ^11.1.0
//     path_provider: ^2.0.0
//     path: ^1.8.0

import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentPath;
  DateTime? _startTime;

  // ── Lifecycle ──

  Future<void> init() async {
    if (_isInitialized) return;
    await _recorder.openRecorder();
    _isInitialized = true;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }

  // ── Permission ──

  /// Minta izin mikrofon. Kembalikan true jika diberikan.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> get hasPermission async =>
      (await Permission.microphone.status).isGranted;

  // ── Recording ──

  /// Mulai merekam. Kembalikan path file yang sedang direkam.
  Future<String> startRecording() async {
    if (!_isInitialized) await init();

    final path = await _buildAudioPath();
    _currentPath = path;
    _startTime = DateTime.now();

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacMP4,       // .m4a — kompatibel iOS & Android
      bitRate: 64000,             // 64kbps cukup untuk rekam suara
      sampleRate: 16000,          // 16kHz — optimal untuk STT (Whisper)
      numChannels: 1,             // Mono — ukuran file lebih kecil
    );

    return path;
  }

  /// Hentikan rekaman. Kembalikan path final dan durasi dalam detik.
  Future<RecordingResult> stopRecording() async {
    if (_currentPath == null) {
      throw StateError('stopRecording dipanggil tanpa startRecording');
    }

    await _recorder.stopRecorder();

    final durationSec = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    final path = _currentPath!;
    _currentPath = null;
    _startTime = null;

    // Validasi file benar-benar ada dan tidak kosong
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File rekaman tidak ditemukan', path);
    }
    final fileSize = await file.length();
    if (fileSize < 1024) {
      // Kurang dari 1KB = hampir pasti gagal
      await file.delete();
      throw Exception('Rekaman terlalu singkat atau gagal disimpan');
    }

    return RecordingResult(path: path, durationSec: durationSec);
  }

  /// Batalkan rekaman tanpa menyimpan.
  Future<void> cancelRecording() async {
    await _recorder.stopRecorder();
    if (_currentPath != null) {
      final file = File(_currentPath!);
      if (await file.exists()) await file.delete();
      _currentPath = null;
    }
    _startTime = null;
  }

  bool get isRecording => _recorder.isRecording;

  /// Stream level suara (0.0 – 1.0) untuk animasi gelombang.
  Stream<double> get amplitudeStream {
    return _recorder
        .onProgress!
        .where((e) => e.decibels != null)
        .map((e) {
          // Normalisasi dB ke 0.0–1.0
          // Whisper-friendly range: -60 dB (senyap) hingga 0 dB (penuh)
          const minDb = -60.0;
          const maxDb = 0.0;
          final db = e.decibels!.clamp(minDb, maxDb);
          return (db - minDb) / (maxDb - minDb);
        });
  }

  // ── File management ──

  /// Bangun path unik: documents/audio/2025-05-04_143022.m4a
  Future<String> _buildAudioPath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(docsDir.path, 'audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll('T', '_')
        .substring(0, 15); // "2025-05-04_1430"

    return p.join(audioDir.path, '$timestamp.m4a');
  }

  /// Hitung total ukuran folder audio (untuk fitur "kelola storage").
  Future<int> getTotalAudioSizeBytes() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(docsDir.path, 'audio'));
    if (!await audioDir.exists()) return 0;

    int total = 0;
    await for (final entity in audioDir.list()) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}

class RecordingResult {
  final String path;
  final int durationSec;

  const RecordingResult({required this.path, required this.durationSec});
}