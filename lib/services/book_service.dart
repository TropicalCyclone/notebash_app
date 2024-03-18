import 'dart:convert';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/book.dart';
import 'package:sqflite/sqflite.dart';

class BookService {
  final Database db;

  BookService({required this.db});

  Future<Book> add(Book book) async {
    final id = await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return book.copy(id: id);
  }

  Future<List<Book>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'books',
      orderBy: 'year_published DESC, title ASC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Book.fromMap(e)).toList();
  }

  Future<Book> update(Book book) async {
    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );

    return book;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<Book> books = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          books.map((book) => book.toMap()).toList();

      final filePath = '$folder/books.json';
      final exportFile = File(filePath);

      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export books');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);
      for (var item in decodedList) {
        final book = Book(
          id: item['id'],
          userId: item['user_id'],
          title: item['title'],
          yearPublished: item['year_published'],
          authors: item['authors'],
        );
        await add(book);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to import books');
    }
  }
}
