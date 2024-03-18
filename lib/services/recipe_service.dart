import 'dart:convert';
import 'dart:io';
import 'package:notebash_app/models/action_result.dart';
import 'package:notebash_app/models/recipe.dart';
import 'package:sqflite/sqflite.dart';

class RecipeService {
  final Database db;

  RecipeService({required this.db});

  Future<Recipe> add(Recipe recipe) async {
    final id = await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return recipe.copy(id: id);
  }

  Future<List<Recipe>> getByUserId(int userId) async {
    final List<Map<String, dynamic>> res = await db.query(
      'recipes',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Recipe.fromMap(e)).toList();
  }

  Future<Recipe> update(Recipe recipe) async {
    await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );

    return recipe;
  }

  Future<void> delete(int id) async {
    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActionResult> export(int userId, String folder) async {
    try {
      final List<Recipe> recipes = await getByUserId(userId);
      List<Map<String, dynamic>> list =
          recipes.map((recipe) => recipe.toMap()).toList();

      final exportFile = File('$folder/recipes.json');
      await exportFile.writeAsString(json.encode(list));

      return ActionResult(success: true, data: list);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to export recipes');
    }
  }

  Future<ActionResult> import(String content) async {
    try {
      final List<dynamic> decodedList = json.decode(content);
      for (var item in decodedList) {
        final recipe = Recipe(
          id: item['id'],
          userId: item['user_id'],
          name: item['name'],
          ingredients: item['ingredients'],
          directions: item['directions'],
          color: item['color'],
        );
        await add(recipe);
      }

      return ActionResult(success: true);
    } catch (e) {
      return ActionResult(success: false, message: 'Failed to import recipes');
    }
  }
}
