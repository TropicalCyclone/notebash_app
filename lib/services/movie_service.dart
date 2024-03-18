import 'dart:convert';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/movie.dart' as model;
import 'package:notebash_app/models/movie.dart';
import 'package:sqflite/sqflite.dart';

class MovieService {
  final Database db;

  MovieService({required this.db});

  Future<model.Movie> add(Movie movie) async {
    final id = await db.insert(
      'movies',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return movie.copy(id: id);
  }

  Future<List<model.Movie>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'movies',
      orderBy: 'year DESC, title ASC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => model.Movie.fromMap(e)).toList();
  }

  Future<model.Movie> update(model.Movie movie) async {
    await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );

    return movie;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<model.Movie> movies = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          movies.map((movie) => movie.toMap()).toList();

      final filePath = '$folder/movies.json';
      final exportFile = File(filePath);

      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export movies');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);
      for (var item in decodedList) {
        final movie = model.Movie(
            id: item['id'],
            userId: item['user_id'],
            title: item['title'],
            year: item['year'],
            genre: item['genre'],
            link: item['link']);
        await add(movie);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to import movies');
    }
  }
}
