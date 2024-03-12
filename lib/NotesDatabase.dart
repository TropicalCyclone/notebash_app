import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class NotesDatabase {
  static Database? _database;
  static const String dbName = 'notes.db';
  static const String notesTable = 'notes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $notesTable(id INTEGER PRIMARY KEY, userId INTEGER, title TEXT, description TEXT, dateCreated TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertNote(Note note) async {
    final Database db = await database;
    await db.insert(
      notesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotesByUserId(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        userId: maps[i]['userId'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        dateCreated: DateTime.parse(maps[i]['dateCreated']),
      );
    });
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(Note note) async {
    final db = await database;
    await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> importNotes(String jsonContent) async {
    List<dynamic> decodedList = json.decode(jsonContent);
    for (var item in decodedList) {
      Note note = Note(
        userId: item['userId'],
        title: item['title'],
        description: item['description'],
        dateCreated: DateTime.parse(item['dateCreated']),
      );
      await insertNote(note);
    }
  }

  Future<String> exportNotes(int userId) async {
    final List<Note> notes = await getNotesByUserId(userId);
    List<Map<String, dynamic>> exportList = notes.map((note) => note.toMap()).toList();

    // Get the directory for storing exported files (documents directory)
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

    String filePath = '${appDocumentsDirectory.path}/notes_export.json';
    File exportFile = File(filePath);
    await exportFile.writeAsString(json.encode(exportList));
    return filePath;
  }

  Future<String> exportSingleNote(int noteId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: 'id = ?',
      whereArgs: [noteId],
    );
    if (maps.isNotEmpty) {
      Note note = Note(
        id: maps[0]['id'],
        userId: maps[0]['userId'],
        title: maps[0]['title'],
        description: maps[0]['description'],
        dateCreated: DateTime.parse(maps[0]['dateCreated']),
      );
      return json.encode(note.toMap());
    } else {
      throw Exception('Note not found');
    }
  }
}

class Note {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final DateTime dateCreated;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }
}
