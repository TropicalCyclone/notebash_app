import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDb() async {
  return openDatabase(join(await getDatabasesPath(), 'note_bash.db'),
      onCreate: (db, version) async {
    await db.execute(
      "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, description TEXT, color INTEGER, date_created TEXT)",
    );
    await db.execute(
      "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT);",
    );
    await db.execute(
      "CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, log_date TEXT);",
    );
    await db.execute(
      "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, name TEXT, is_done INTEGER, date_created TEXT);",
    );
  }, version: 1);
}
