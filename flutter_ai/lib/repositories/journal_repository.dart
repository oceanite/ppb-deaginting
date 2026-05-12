// lib/repositories/journal_repository.dart
//
// Repository adalah satu-satunya pintu masuk ke data.
// Logika bisnis TIDAK boleh menyentuh database atau file system secara langsung.

import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../models/empathy_map_data.dart';

// Tambahkan ke pubspec.yaml:
//   dependencies:
//     uuid: ^4.3.3

class JournalRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  JournalRepository(this._db);

  // ── Stream (reaktif, UI otomatis update) ──

  /// Semua jurnal, real-time. Gunakan ini di UI via StreamBuilder atau Riverpod.
  Stream<List<JournalWithEmpathyMap>> watchAll() => _db.watchAllJournals();

  // ── Read ──

  Future<JournalWithEmpathyMap?> getById(String id) =>
      _db.getJournalById(id);

  // ── Write: Alur normal satu sesi rekam ──

  /// Langkah 1 — Buat entri jurnal segera setelah rekaman selesai.
  /// Kembalikan id yang bisa dipakai untuk update selanjutnya.
  Future<String> createJournal({
    required String audioPath,
    required int durationSec,
  }) async {
    final id = _uuid.v4();
    await _db.insertJournal(
      JournalsCompanion.insert(
        id: id,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        audioPath: audioPath,
        durationSec: Value(durationSec),
        status: const Value('pending'),
      ),
    );
    return id;
  }

  /// Langkah 2 — Tandai sedang diproses AI.
  Future<void> markProcessing(String journalId) =>
      _db.updateJournalStatus(id: journalId, status: 'processing');

  /// Langkah 3 — Simpan hasil analisis AI setelah berhasil.
  Future<void> saveResult({
    required String journalId,
    required String transcript,
    required EmpathyMapData result,
  }) async {
    final empathyId = _uuid.v4();

    // Simpan empathy map sebagai JSON string
    final mapJson = jsonEncode({
      'feelings': result.empathyMap.feelings,
      'thoughts': result.empathyMap.thoughts,
      'pain_points': result.empathyMap.painPoints,
      'actions': result.empathyMap.actions,
    });

    // Update journal: transcript + status done
    await _db.updateJournalStatus(
      id: journalId,
      status: 'done',
      transcript: transcript,
    );

    // Insert empathy map
    await _db.insertEmpathyMap(
      EmpathyMapsCompanion.insert(
        id: empathyId,
        journalId: journalId,
        dominantEmotion: result.dominantEmotion,
        colorHex: _colorToHex(result.colorHex),
        mapJson: mapJson,
        analyzedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Insert tag-tag emosi untuk keperluan filter
    final tags = _extractTags(result.dominantEmotion);
    await _db.insertTags(
      tags.map((tag) => EmotionTagsCompanion.insert(
            id: _uuid.v4(),
            journalId: journalId,
            tag: tag,
          )).toList(),
    );
  }

  /// Langkah 3 (alternatif) — Tandai error jika AI pipeline gagal.
  Future<void> markError(String journalId) =>
      _db.updateJournalStatus(id: journalId, status: 'error');

  // ── Delete ──

  /// Hapus jurnal beserta file audio-nya dari storage.
  Future<void> deleteJournal(String journalId) async {
    final entry = await _db.getJournalById(journalId);
    if (entry != null) {
      // Hapus file audio dari file system
      final audioFile = File(entry.journal.audioPath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
    }
    await _db.deleteJournal(journalId);
  }

  // ── Filter ──

  Future<List<String>> getAllTags() => _db.getAllUniqueTags();

  Future<List<Journal>> getByTag(String tag) => _db.getJournalsByTag(tag);

  // ── Helpers ──

  String _colorToHex(dynamic color) {
    // color bisa berupa Color (Flutter) atau String hex
    if (color is String) return color;
    // Dari Color object: ambil 6 digit terakhir sebagai hex
    final value = color.value as int;
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// "Lelah & Cemas" → ["lelah", "cemas"]
  List<String> _extractTags(String dominantEmotion) {
    return dominantEmotion
        .toLowerCase()
        .split(RegExp(r'[&,/\s]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}