import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'database_helper.dart';

class ClassDao {
  final _h = DatabaseHelper.instance;

  Future<List<ClassModel>> getAll() async {
    final d = await _h.db;
    final rows =
        await d.query('classes', orderBy: 'day_of_week, start_time');
    return rows.map(ClassModel.fromMap).toList();
  }

  Future<ClassModel?> getById(String id) async {
    final d = await _h.db;
    final rows =
        await d.query('classes', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ClassModel.fromMap(rows.first);
  }

  Future<void> upsert(ClassModel c) async {
    final d = await _h.db;
    await d.insert('classes', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertAll(List<ClassModel> classes) async {
    final d = await _h.db;
    final batch = d.batch();
    for (final c in classes) {
      batch.insert('classes', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> delete(String id) async {
    final d = await _h.db;
    await d.delete('classes', where: 'id = ?', whereArgs: [id]);
  }
}