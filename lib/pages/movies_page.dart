import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/movie_actions.dart';
import 'package:notebash_app/components/movie_item.dart';
import 'package:notebash_app/models/movie.dart';
import 'package:notebash_app/pages/movie_entry_page.dart';
import 'package:notebash_app/services/movie_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MoviesPage extends StatefulWidget {
  final int userId;
  final Database _db;

  const MoviesPage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  List<Movie> _movies = [];
  late MovieService _service;

  @override
  void initState() {
    super.initState();
    _movies = [];
    _service = MovieService(db: widget._db);
  }

  Future<void> _load() async {
    var movies = await _service.getByUserId(widget.userId);
    _movies = movies;
  }

  Future<void> _exportMovies() async {
    if (!await tryGrantPermission()) {
      if (mounted) showSnackBar(context, "Access denied", error: true);
      return;
    }

    String? folder = await FilePicker.platform.getDirectoryPath();

    if (folder == null) return;

    final result = await _service.export(widget.userId, folder);

    if (result.success) {
      if (mounted) {
        showSnackBar(
            context, 'File exported successfully to $folder\\movies.json');
      }
    } else {
      if (mounted) showSnackBar(context, result.message!, error: true);
    }
  }

  Future<void> onImport(String contents) async {
    final result = await _service.import(contents);
    if (result.success) {
      await _load();
      setState(() {});
      if (mounted) showSnackBar(context, 'Movies imported successfully');
    } else {
      if (mounted) showSnackBar(context, result.message!, error: true);
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(15),
          topStart: Radius.circular(15),
        ),
      ),
      builder: (context) => MovieActions(
        movieEntryPage: MovieEntryPage(
            userId: widget.userId,
            db: widget._db,
            onSave: () async {
              await _load();
              setState(() {});
            }),
        onImport: (contents) => onImport(contents),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<void>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  SizedBox(
                    child: SvgPicture.asset(
                      "assets/images/clapper.svg",
                      semanticsLabel: "Movies",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Movies'),
                ],
              ),
            ),
            body: Text(
              'Loading...',
              style: theme.textTheme.labelMedium,
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  SizedBox(
                    child: SvgPicture.asset(
                      "assets/images/clapper.svg",
                      semanticsLabel: "Movies",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Movies'),
                ],
              ),
              leading: IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.chevron_left),
              ),
              actions: [
                IconButton(
                  onPressed: _movies.isEmpty ? null : () => _exportMovies(),
                  icon: const Icon(Icons.upload),
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: _movies.length,
              itemBuilder: (context, index) => MovieItem(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieEntryPage(
                      userId: widget.userId,
                      db: widget._db,
                      movie: _movies[index],
                      onSave: () async {
                        await _load();
                        setState(() {});
                      },
                    ),
                  ),
                ),
                movie: _movies[index],
              ),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              onPressed: () => _showOptions(context),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
