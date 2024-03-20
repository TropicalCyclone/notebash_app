import 'dart:convert';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/travel.dart';
import 'package:sqflite/sqflite.dart';

class TravelService {
  final Database db;

  TravelService({required this.db});

  Future<Travel> add(Travel travel) async {
    final id = await db.insert(
      'travels',
      travel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return travel.copy(id: id);
  }

  Future<List<Travel>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'travels',
      orderBy: 'travel_date DESC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Travel.fromMap(e)).toList();
  }

  Future<Travel> update(Travel travel) async {
    await db.update(
      'travels',
      travel.toMap(),
      where: 'id = ?',
      whereArgs: [travel.id],
    );

    return travel;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'travels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<Travel> travels = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          travels.map((note) => note.toMap()).toList();

      final exportFile = File('$folder/travels.json');
      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(
          success: false, message: 'Failed to export travel destinations');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);

      for (var item in decodedList) {
        final travel = Travel.fromMap(item);
        await add(travel);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(
          success: false, message: 'Failed to import travel destinations');
    }
  }
}
