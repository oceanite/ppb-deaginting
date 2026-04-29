import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'database_helper.dart';

class LocalCache {
  static final LocalCache instance = LocalCache._();
  LocalCache._();

  final _h = DatabaseHelper.instance;

  // ── Classes ───────────────────────────────────────────────────────────────

  Future<void> cacheClasses(List<ClassModel> classes) async {
    final d = await _h.db;
    final batch = d.batch();
    for (final c in classes) {
      batch.insert('classes', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<ClassModel>> getCachedClasses() async {
    final d = await _h.db;
    final rows = await d.query('classes', orderBy: 'day_of_week, start_time');
    return rows.map(ClassModel.fromMap).toList();
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<void> cacheActivities(List<ActivityModel> activities) async {
    final d = await _h.db;
    final batch = d.batch();
    for (final a in activities) {
      batch.insert('activities', a.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<ActivityModel>> getCachedActivities(String asdosId) async {
    final d = await _h.db;
    final rows = await d.query(
      'activities',
      where: 'asdos_id = ?',
      whereArgs: [asdosId],
      orderBy: 'created_at DESC',
    );
    return rows.map(ActivityModel.fromMap).toList();
  }

  Future<void> updateCachedStatus(
    String id,
    ActivityStatus status, {
    String? rejectReason,
  }) async {
    final d = await _h.db;
    await d.update(
      'activities',
      {
        'status': status.name,
        if (rejectReason != null) 'reject_reason': rejectReason,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCachedPhotoUrl(String id, String url) async {
    final d = await _h.db;
    await d.update(
      'activities',
      {'photo_url': url},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() => _h.clearAll();
}