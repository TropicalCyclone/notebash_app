import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/models/movie.dart' as model;
import 'package:notebash_app/services/movie_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MovieEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final model.Movie? movie;

  const MovieEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.movie,
  });

  @override
  State<MovieEntryPage> createState() => _MovieEntryPageState();
}

class _MovieEntryPageState extends State<MovieEntryPage> {
  late MovieService _service;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String _errorMessage = '';
  String _yearError = '';

  @override
  void initState() {
    super.initState();

    _service = MovieService(db: widget.db);
    if (widget.movie != null) {
      _titleController.text = widget.movie!.title;
      _yearController.text = widget.movie!.year.toString();
      _genreController.text = widget.movie!.genre;
      _linkController.text = widget.movie!.link;
    } else {
      _titleController.clear();
      _yearController.clear();
      _genreController.clear();
      _linkController.clear();
    }

    _errorMessage = '';
    _yearError = '';
  }

  Future<void> _saveMovie() async {
    if (int.tryParse(_yearController.text) == null) {
      setState(() {
        _yearError = 'Year must be a number';
      });
      return;
    }

    if (_titleController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _linkController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    final movie = model.Movie(
      userId: widget.userId,
      title: _titleController.text,
      year: int.parse(_yearController.text),
      genre: _genreController.text,
      link: _linkController.text,
    );
    await _service.add(movie);
    widget.onSave();
    _close();
    _showSnackBar('Movie has been added');
  }

  Future<void> _updateMovie() async {
    if (_titleController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _linkController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (widget.movie != null) {
      if (int.tryParse(_yearController.text) == null) {
        setState(() {
          _yearError = 'Invalid value';
        });
        return;
      }

      final movie = model.Movie(
        id: widget.movie!.id,
        userId: widget.userId,
        title: _titleController.text,
        year: int.parse(_yearController.text),
        genre: _genreController.text,
        link: _linkController.text,
      );
      await _service.update(movie);
      widget.onSave();
      _close();
      _showSnackBar('Movie has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Movie'),
          content: const Text('Are you sure you want to delete this movie?'),
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
              onPressed: () => _deleteMovie(),
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

  Future<void> _deleteMovie() async {
    _close();

    if (widget.movie != null) {
      await _service.delete(widget.movie!.id!);
      widget.onSave();
      _close();
      _showSnackBar('Movie has been deleted');
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
                "assets/images/clapper.svg",
                semanticsLabel: "Movie Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.movie == null ? 'New Movie' : 'Edit Movie'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.movie == null
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
                  "Title",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter title',
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
                  "Genre",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _genreController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter genre',
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
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Year",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _yearController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter release year',
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
              ),
              if (_yearError.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _yearError,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Link",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter link',
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
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () =>
                      widget.movie != null ? _updateMovie() : _saveMovie(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Movie',
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
