// lib/data/database/app_database.dart
//
// Drift (type-safe SQLite ORM untuk Flutter).
// Untuk generate kode, jalankan: dart run build_runner build
//
// Tambahkan ke pubspec.yaml:
//   dependencies:
//     drift: ^2.14.0
//     sqlite3_flutter_libs: ^0.5.0
//     path_provider: ^2.0.0
//     path: ^1.8.0
//   dev_dependencies:
//     drift_dev: ^2.14.0
//     build_runner: ^2.4.0

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart'; // di-generate oleh build_runner

// ─────────────────────────────────────────────
// TABLE DEFINITIONS
// ─────────────────────────────────────────────

/// Satu sesi rekam = satu Journal.
class Journals extends Table {
  /// UUID v4 dibuat di sisi app (tidak auto-increment agar bisa offline-first).
  TextColumn get id => text()();

  /// Unix timestamp milidetik saat rekaman selesai.
  IntColumn get createdAt => integer()();

  /// Path absolut file .m4a di documents directory.
  TextColumn get audioPath => text()();

  /// Transkripsi teks dari Whisper API. Null saat proses belum selesai.
  TextColumn get transcript => text().nullable()();

  /// Durasi rekaman dalam detik.
  IntColumn get durationSec => integer().withDefault(const Constant(0))();

  /// Enum: 'pending' | 'processing' | 'done' | 'error'
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Hasil analisis AI untuk satu Journal.
class EmpathyMaps extends Table {
  TextColumn get id => text()();

  /// FK ke Journals.id
  TextColumn get journalId => text().references(Journals, #id)();

  TextColumn get dominantEmotion => text()();

  /// Hex code warna, misal "#2C3E50"
  TextColumn get colorHex => text()();

  /// Seluruh empathy map disimpan sebagai JSON string.
  /// Struktur: {"feelings":[...],"thoughts":[...],"pain_points":[...],"actions":[...]}
  TextColumn get mapJson => text()();

  /// Unix timestamp saat data AI diterima.
  IntColumn get analyzedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tag emosi yang di-extract dari dominant_emotion untuk keperluan filter & analitik.
class EmotionTags extends Table {
  TextColumn get id => text()();
  TextColumn get journalId => text().references(Journals, #id)();

  /// Satu kata emosi, misal "lelah", "cemas", "bahagia"
  TextColumn get tag => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────
// DATABASE CLASS
// ─────────────────────────────────────────────

@DriftDatabase(tables: [Journals, EmpathyMaps, EmotionTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Index untuk mempercepat query history berurutan waktu
          await customStatement(
            'CREATE INDEX idx_journals_created_at ON journals(created_at DESC)',
          );
          // Index untuk filter berdasarkan tag
          await customStatement(
            'CREATE INDEX idx_emotion_tags_tag ON emotion_tags(tag)',
          );
        },
        onUpgrade: (m, from, to) async {
          // Migrasi skema di sini untuk versi selanjutnya
        },
      );

  // ── Journal queries ──

  /// Semua jurnal diurutkan dari terbaru, dengan empathy map jika ada.
  Stream<List<JournalWithEmpathyMap>> watchAllJournals() {
    final query = select(journals).join([
      leftOuterJoin(
        empathyMaps,
        empathyMaps.journalId.equalsExp(journals.id),
      ),
    ])
      ..orderBy([OrderingTerm.desc(journals.createdAt)]);

    return query.watch().map((rows) => rows.map((row) {
          return JournalWithEmpathyMap(
            journal: row.readTable(journals),
            empathyMap: row.readTableOrNull(empathyMaps),
          );
        }).toList());
  }

  /// Satu jurnal berdasarkan id, termasuk empathy map-nya.
  Future<JournalWithEmpathyMap?> getJournalById(String id) async {
    final query = select(journals).join([
      leftOuterJoin(
        empathyMaps,
        empathyMaps.journalId.equalsExp(journals.id),
      ),
    ])
      ..where(journals.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return JournalWithEmpathyMap(
      journal: row.readTable(journals),
      empathyMap: row.readTableOrNull(empathyMaps),
    );
  }

  /// Insert jurnal baru (status 'pending') saat rekaman dimulai.
  Future<void> insertJournal(JournalsCompanion entry) =>
      into(journals).insert(entry);

  /// Update status dan transcript setelah proses AI selesai.
  Future<void> updateJournalStatus({
    required String id,
    required String status,
    String? transcript,
  }) =>
      (update(journals)..where((j) => j.id.equals(id))).write(
        JournalsCompanion(
          status: Value(status),
          transcript: transcript != null ? Value(transcript) : const Value.absent(),
        ),
      );

  /// Hapus jurnal beserta empathy map dan tags-nya (cascade via FK).
  Future<void> deleteJournal(String id) async {
    await (delete(empathyMaps)..where((e) => e.journalId.equals(id))).go();
    await (delete(emotionTags)..where((t) => t.journalId.equals(id))).go();
    await (delete(journals)..where((j) => j.id.equals(id))).go();
  }

  // ── EmpathyMap queries ──

  Future<void> insertEmpathyMap(EmpathyMapsCompanion entry) =>
      into(empathyMaps).insert(entry);

  // ── Tag queries ──

  Future<void> insertTags(List<EmotionTagsCompanion> entries) =>
      batch((b) => b.insertAll(emotionTags, entries));

  /// Semua tag unik, untuk tampilan filter/cloud.
  Future<List<String>> getAllUniqueTags() async {
    final query = selectOnly(emotionTags, distinct: true)
      ..addColumns([emotionTags.tag]);
    final result = await query.get();
    return result.map((r) => r.read(emotionTags.tag)!).toList();
  }

  /// Jurnal berdasarkan tag tertentu.
  Future<List<Journal>> getJournalsByTag(String tag) async {
    final taggedIds = await (select(emotionTags)
          ..where((t) => t.tag.equals(tag)))
        .map((t) => t.journalId)
        .get();

    return (select(journals)
          ..where((j) => j.id.isIn(taggedIds))
          ..orderBy([(j) => OrderingTerm.desc(j.createdAt)]))
        .get();
  }
}

// ─────────────────────────────────────────────
// COMPANION MODEL
// ─────────────────────────────────────────────

class JournalWithEmpathyMap {
  final Journal journal;
  final EmpathyMap? empathyMap;

  const JournalWithEmpathyMap({
    required this.journal,
    this.empathyMap,
  });

  bool get hasResult => empathyMap != null;
  bool get isProcessing => journal.status == 'processing';
  bool get hasError => journal.status == 'error';
}

// ─────────────────────────────────────────────
// CONNECTION HELPER
// ─────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hei_penyu.db'));
    return NativeDatabase.createInBackground(file);
  });
}