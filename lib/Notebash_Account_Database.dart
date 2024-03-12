import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'User.dart';

class NoteBashAccountDatabase {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'notebash_accounts.db'),
      onCreate: _createDB,
      version: 1,
    );
  }

  Future<void> _createDB(Database database, int version) async {
    await database.execute(
      "CREATE TABLE accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT);",
    );
    //await database.execute(
    //  "INSERT INTO accounts(username, password) VALUES ('user', 'password')",
    //);
  }

  Future<int> insertAccount(User user) async {
    final db = await initializeDB();
    int result = await db.insert(
      'accounts',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<bool> checkLogin(String username, String password) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return accounts.isNotEmpty;
  }

  Future<int> getUserId(String username) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (accounts.isNotEmpty) {
      return accounts.first['id'];
    } else {
      return -1;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'username = ?',
      whereArgs: [username],
    );
    return accounts.isNotEmpty;
  }
}
