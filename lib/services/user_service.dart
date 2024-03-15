import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserService {
  final Database _db;

  UserService({required Database db}) : _db = db;

  Future<ActionResult<User>> register(User user) async {
    if (await _isAlreadyExist(user.username)) {
      return ActionResult<User>(
        success: false,
        message: 'Username already exist',
      );
    }

    final id = await _db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return ActionResult<User>(
      success: true,
      data: user.copy(id: id),
    );
  }

  Future<bool> _isAlreadyExist(String username) async {
    final List<Map<String, dynamic>> users = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return users.isNotEmpty;
  }

  Future<ActionResult<User>> login(String username, String password) async {
    final user = await _getUserByUserName(username);

    if (user == null) {
      return ActionResult<User>(
        success: false,
        message: 'User not found',
      );
    }

    if (user.password != password) {
      return ActionResult<User>(
        success: false,
        message: 'Incorrect password',
      );
    }

    await _db.delete('logs');
    await _db.insert(
      'logs',
      {
        'id': 1,
        'user_id': user.id,
        'log_date': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return ActionResult<User>(
      success: true,
      data: user,
    );
  }

  Future<User?> _getUserByUserName(String username) async {
    final List<Map<String, dynamic>> users = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (users.isNotEmpty) {
      return User.fromMap(users.first);
    } else {
      return null;
    }
  }
}
