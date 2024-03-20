import 'dart:convert';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/expense.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseService {
  final Database db;

  ExpenseService({required this.db});

  Future<Expense> add(Expense travel) async {
    final id = await db.insert(
      'expenses',
      travel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return travel.copy(id: id);
  }

  Future<List<Expense>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'expenses',
      orderBy: 'date DESC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Expense.fromMap(e)).toList();
  }

  Future<Expense> update(Expense travel) async {
    await db.update(
      'expenses',
      travel.toMap(),
      where: 'id = ?',
      whereArgs: [travel.id],
    );

    return travel;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<Expense> expenses = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          expenses.map((note) => note.toMap()).toList();

      final exportFile = File('$folder/expenses.json');
      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export expenses');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);

      for (var item in decodedList) {
        final travel = Expense.fromMap(item);
        await add(travel);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to import expenses');
    }
  }
}
