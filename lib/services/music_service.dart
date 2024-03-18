import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/music.dart';
import 'package:sqflite/sqflite.dart';

class MusicService {
  final Database db;

  MusicService({required this.db});

  Future<Music> add(Music music) async {
    final id = await db.insert(
      'musics',
      music.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return music.copy(id: id);
  }

  Future<List<Music>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'musics',
      orderBy: 'title ASC',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Music.fromMap(e)).toList();
  }

  Future<Music> update(Music music) async {
    await db.update(
      'musics',
      music.toMap(),
      where: 'id = ?',
      whereArgs: [music.id],
    );

    return music;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'musics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<Music> musics = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          musics.map((music) => music.toMap()).toList();

      final filePath = '$folder/musics.json';
      final exportFile = File(filePath);

      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export musics');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);

      for (var item in decodedList) {
        final music = Music(
            id: item['id'],
            userId: item['user_id'],
            title: item['title'],
            artist: item['artist'],
            album: item['album'],
            albumArt: item['album_art'],
            url: item['url']);
        await add(music);
      }

      return ActionResult(success: true);
    } catch (e) {
      log(e.toString());
      return ActionResult(success: false, message: 'Failed to import musics');
    }
  }
}
