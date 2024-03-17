import 'dart:convert';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/task.dart' as model;
import 'package:notebash_app/models/task.dart';
import 'package:sqflite/sqflite.dart';

class TaskService {
  final Database db;

  TaskService({required this.db});

  Future<model.Task> add(Task task) async {
    final id = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return task.copy(id: id);
  }

  Future<List<model.Task>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'tasks',
      orderBy: 'date_created DESC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => model.Task.fromMap(e)).toList();
  }

  Future<model.Task> update(model.Task task) async {
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    return task;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<model.Task> tasks = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          tasks.map((task) => task.toMap()).toList();

      final filePath = '$folder/tasks.json';
      final exportFile = File(filePath);

      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export tasks');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);
      for (var item in decodedList) {
        final note = model.Task(
          id: item['id'],
          userId: item['user_id'],
          name: item['name'],
          isDone: item['is_done'] == 1,
          dateCreated: DateTime.parse(item['date_created']),
        );
        await add(note);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to import tasks');
    }
  }
}
