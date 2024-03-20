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
    await db.execute(
      "CREATE TABLE movies(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, year INTEGER, genre TEXT, link TEXT);",
    );
    await db.execute(
      "CREATE TABLE books(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, year_published INTEGER, authors TEXT);",
    );
    await db.execute(
      "CREATE TABLE musics(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, artist TEXT, album TEXT, album_art TEXT, url TEXT);",
    );
    await db.execute(
      "CREATE TABLE recipes(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, name TEXT, ingredients TEXT, directions TEXT, color INTEGER);",
    );
    await db.execute(
      "CREATE TABLE travels(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, destination TEXT, travel_date TEXT);",
    );
    await db.execute(
      "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, category TEXT, amount REAL, date TEXT);",
    );
  }, version: 1);
}
