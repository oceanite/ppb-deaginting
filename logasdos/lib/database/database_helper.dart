import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'logasdos_cache.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
    );
  }

  Future<void> _create(Database d, int _) async {
    await d.execute('''
      CREATE TABLE classes (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        dosen_id    TEXT NOT NULL,
        dosen_name  TEXT NOT NULL DEFAULT '',
        start_time  TEXT NOT NULL,
        end_time    TEXT NOT NULL,
        room        TEXT NOT NULL,
        is_online   INTEGER NOT NULL DEFAULT 0,
        day_of_week INTEGER NOT NULL DEFAULT 1,
        cached_at   TEXT DEFAULT (datetime('now'))
      )''');

    await d.execute('''
      CREATE TABLE activities (
        id            TEXT PRIMARY KEY,
        class_id      TEXT NOT NULL,
        class_name    TEXT NOT NULL DEFAULT '',
        asdos_id      TEXT NOT NULL,
        asdos_name    TEXT NOT NULL DEFAULT '',
        category      TEXT NOT NULL,
        description   TEXT NOT NULL,
        photo_path    TEXT,
        photo_url     TEXT,
        status        TEXT NOT NULL DEFAULT 'pending',
        is_online     INTEGER NOT NULL DEFAULT 0,
        date          TEXT NOT NULL,
        time_range    TEXT NOT NULL,
        reject_reason TEXT,
        created_at    TEXT NOT NULL,
        cached_at     TEXT DEFAULT (datetime('now'))
      )''');

    await d.execute('CREATE INDEX idx_act_asdos  ON activities(asdos_id)');
    await d.execute('CREATE INDEX idx_act_status ON activities(status)');
  }

  Future<void> clearAll() async {
    final d = await db;
    await d.delete('activities');
    await d.delete('classes');
  }
}