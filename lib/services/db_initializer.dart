import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDb() async {
  return openDatabase(join(await getDatabasesPath(), 'note_bash.db'),
      onCreate: (db, version) async {
    await db.execute(
      "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, description TEXT, color TEXT, date_created TEXT)",
    );
    await db.execute(
      "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT);",
    );
  }, version: 1);
}
