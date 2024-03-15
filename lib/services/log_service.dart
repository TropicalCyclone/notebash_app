import 'package:notebash_app/models/log.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LogService {
  final Database db;

  LogService({required this.db});

  Future<void> add(Log log) async {
    await db.insert(
      'logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Log?> get() async {
    final List<Map<String, dynamic>> res = await db.query(
      'logs',
      orderBy: 'log_date DESC',
      limit: 1,
    );
    if (res.isEmpty) return null;
    return Log.fromMap(res.first);
  }

  Future<void> delete(int id) async {
    await db.delete(
      'logs',
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }
}
