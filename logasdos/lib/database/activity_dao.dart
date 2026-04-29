import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'database_helper.dart';

class ActivityDao {
  final _h = DatabaseHelper.instance;

  Future<void> insert(ActivityModel a) async {
    final d = await _h.db;
    await d.insert('activities', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertAll(List<ActivityModel> list) async {
    final d = await _h.db;
    final batch = d.batch();
    for (final a in list) {
      batch.insert('activities', a.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<ActivityModel>> getByAsdos(String asdosId) async {
    final d = await _h.db;
    final rows = await d.query(
      'activities',
      where: 'asdos_id = ?',
      whereArgs: [asdosId],
      orderBy: 'created_at DESC',
    );
    return rows.map(ActivityModel.fromMap).toList();
  }

  Future<ActivityModel?> getById(String id) async {
    final d = await _h.db;
    final rows =
        await d.query('activities', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ActivityModel.fromMap(rows.first);
  }

  Future<ActivityStats> getStats(String asdosId) async {
    final d = await _h.db;
    final rows = await d.rawQuery('''
      SELECT
        COUNT(*) as total,
        SUM(CASE WHEN status='approved'  THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN status='pending'   THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN status='rejected'  THEN 1 ELSE 0 END) as rejected
      FROM activities WHERE asdos_id = ?
    ''', [asdosId]);
    final r = rows.first;
    return ActivityStats(
      total: (r['total'] as int?) ?? 0,
      approved: (r['approved'] as int?) ?? 0,
      pending: (r['pending'] as int?) ?? 0,
      rejected: (r['rejected'] as int?) ?? 0,
    );
  }

  Future<void> updateStatus(
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

  Future<void> delete(String id) async {
    final d = await _h.db;
    await d.delete('activities', where: 'id = ?', whereArgs: [id]);
  }
}