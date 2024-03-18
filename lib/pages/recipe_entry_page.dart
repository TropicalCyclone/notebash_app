import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/color_selection.dart';
import 'package:notebash_app/models/recipe.dart';
import 'package:notebash_app/services/recipe_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RecipeEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final Recipe? recipe;

  const RecipeEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.recipe,
  });

  @override
  State<RecipeEntryPage> createState() => _RecipeEntryPageState();
}

class _RecipeEntryPageState extends State<RecipeEntryPage> {
  late RecipeService _service;
  int? _selectedColor;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _directionsController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _service = RecipeService(db: widget.db);
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _ingredientsController.text = widget.recipe!.ingredients;
      _directionsController.text = widget.recipe!.directions;
    } else {
      _nameController.clear();
      _ingredientsController.clear();
      _directionsController.clear();
    }

    _selectedColor = widget.recipe?.color;
    _errorMessage = '';
  }

  void _onColorChanged(int color) {
    _selectedColor = color;
  }

  Future<void> _saveRecipe() async {
    if (_nameController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _directionsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    final recipe = Recipe(
      userId: widget.userId,
      name: _nameController.text,
      ingredients: _ingredientsController.text,
      directions: _directionsController.text,
      color: _selectedColor ?? 0XFFDFE2EB,
    );
    await _service.add(recipe);
    widget.onSave();
    _close();
    _showSnackBar('Recipe has been added');
  }

  Future<void> _updateRecipe() async {
    if (_nameController.text.isEmpty || _ingredientsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Recipe name and ingredients are required';
      });
      return;
    }

    if (widget.recipe != null) {
      final recipe = Recipe(
        id: widget.recipe!.id,
        userId: widget.userId,
        name: _nameController.text,
        ingredients: _ingredientsController.text,
        directions: _directionsController.text,
        color: _selectedColor ?? 0XFFB5DEE9,
      );
      await _service.update(recipe);
      widget.onSave();
      _close();
      _showSnackBar('Recipe has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: const Text('Are you sure you want to delete this recipe?'),
          actions: <Widget>[
            OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel')),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => _deleteRecipe(),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Future<void> _deleteRecipe() async {
    _close();

    if (widget.recipe != null) {
      await _service.delete(widget.recipe!.id!);
      widget.onSave();
      _close();
      _showSnackBar('Recipe has been deleted');
    }
  }

  void _showSnackBar(String message, [bool error = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? Colors.red : null,
        content: Text(
          message,
          style: error
              ? Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Colors.white)
              : null,
        ),
      ),
    );
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              child: SvgPicture.asset(
                "assets/images/chef.svg",
                semanticsLabel: "Chef Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.recipe == null ? 'New Recipe' : 'Edit Recipe'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.recipe == null
            ? null
            : [
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete),
                ),
                const SizedBox(width: 10),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recipe Name",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter recipe name',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 12,
                  ),
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ingredients",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _ingredientsController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter ingredients',
                  contentPadding: const EdgeInsets.all(12),
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Directions",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _directionsController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter directions',
                  contentPadding: const EdgeInsets.all(12),
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Paper Color",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: NoteColors(
                    selectedColor: widget.recipe?.color,
                    colors: const [
                      0XFFB5DEE9,
                      0XFFC9E6C9,
                      0XFFEBE1AB,
                      0XFFF7BAC7,
                      0XFFCAB2D8,
                    ],
                    onColorChanged: _onColorChanged),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () =>
                      widget.recipe != null ? _updateRecipe() : _saveRecipe(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Recipe',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
