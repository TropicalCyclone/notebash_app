import 'dart:convert';
import 'dart:io';

import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/note.dart';
import 'package:sqflite/sqflite.dart';

class NoteService {
  final Database db;

  NoteService({required this.db});

  Future<Note> add(Note note) async {
    final id = await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return note.copy(id: id);
  }

  Future<List<Note>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Note.fromMap(e)).toList();
  }

  Future<Note> update(Note note) async {
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );

    return note;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<Note> notes = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          notes.map((note) => note.toMap()).toList();

      final filePath = '$folder/notes.json';
      final exportFile = File(filePath);

      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export notes');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);
      for (var item in decodedList) {
        final note = Note(
          id: item['id'],
          userId: item['user_id'],
          title: item['title'],
          description: item['description'],
          color: item['color'],
          dateCreated: DateTime.parse(item['date_created']),
        );
        await add(note);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to import notes');
    }
  }
}
