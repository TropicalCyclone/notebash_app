import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/models/music.dart';
import 'package:notebash_app/services/music_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MusicEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final Music? music;

  const MusicEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.music,
  });

  @override
  State<MusicEntryPage> createState() => _MusicEntryPageState();
}

class _MusicEntryPageState extends State<MusicEntryPage> {
  late MusicService _service;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _albumArtController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _service = MusicService(db: widget.db);
    if (widget.music != null) {
      _titleController.text = widget.music!.title;
      _artistController.text = widget.music!.artist;
      _albumController.text = widget.music!.album;
      _albumArtController.text = widget.music!.albumArt;
      _urlController.text = widget.music!.url;
    } else {
      _titleController.clear();
      _artistController.clear();
      _albumController.clear();
      _albumArtController.clear();
      _urlController.clear();
    }

    _errorMessage = '';
  }

  Future<void> _saveMusic() async {
    if (!validateEntries()) return;

    final music = Music(
      userId: widget.userId,
      title: _titleController.text,
      artist: _artistController.text,
      album: _albumController.text,
      albumArt: _albumArtController.text,
      url: _urlController.text,
    );
    await _service.add(music);
    widget.onSave();
    _close();
    _showSnackBar('Music has been added');
  }

  bool validateEntries() {
    if (_titleController.text.isEmpty ||
        _artistController.text.isEmpty ||
        _albumController.text.isEmpty ||
        _albumArtController.text.isEmpty ||
        _urlController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return false;
    }

    return true;
  }

  Future<void> _updateMusic() async {
    if (!validateEntries()) return;

    if (widget.music != null) {
      final music = Music(
        id: widget.music!.id,
        userId: widget.userId,
        title: _titleController.text,
        artist: _artistController.text,
        album: _albumController.text,
        albumArt: _albumArtController.text,
        url: _urlController.text,
      );
      await _service.update(music);
      widget.onSave();
      _close();
      _showSnackBar('Music has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Music'),
          content: const Text('Are you sure you want to delete this music?'),
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
              onPressed: () => _deleteMusic(),
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

  Future<void> _deleteMusic() async {
    _close();

    if (widget.music != null) {
      await _service.delete(widget.music!.id!);
      widget.onSave();
      _close();
      _showSnackBar('Music has been deleted');
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
                "assets/images/music.svg",
                semanticsLabel: "Music Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.music == null ? 'New Music' : 'Edit Music'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.music == null
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
                  "Artist",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _artistController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter artist',
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
                  "Album",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _albumController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter album',
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
                  "Album Art",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _albumArtController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter album art link',
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
                  "URL",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter music URL',
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
                      widget.music != null ? _updateMusic() : _saveMusic(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Music',
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
