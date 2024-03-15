import 'dart:io';
import 'package:intl/intl.dart';
import 'package:notebash_app/models/note.dart';
import 'package:notebash_app/services/note_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/login_page.dart';
import 'package:notebash_app/pages/note_page.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final Database _db;

  const HomePage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];
  late NoteService _service;

  @override
  void initState() {
    super.initState();
    _notes = [];
    _service = NoteService(db: widget._db);
  }

  Future<void> _refreshNotes() async {
    var notes = await _service.getByUserId(widget.userId);
    _notes = notes;
  }

  Future<void> _importNote() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (fileResult != null) {
      final file = File(fileResult.files.single.path!);
      final contents = await file.readAsString();
      final result = await _service.import(contents);
      if (result.success) {
        await _refreshNotes();
      } else {
        showSnackBar(result.message!);
      }
    }
  }

  Future<void> _exportDatabase() async {
    String? folder = await FilePicker.platform.getDirectoryPath();

    if (folder == null) return;

    final result = await _service.export(widget.userId, folder);

    if (result.success) {
      showSnackBar('File exported successfully to $folder/notes.json');
    } else {
      showSnackBar(result.message!);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Create New Note'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotePage(
                        userId: widget.userId,
                        db: widget._db,
                      ),
                    ),
                  ).then((value) async {
                    await _refreshNotes();
                    setState(() {});
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Import Note'),
                onTap: () async {
                  await _importNote();
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<void>(
      future: _refreshNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('NoteBash'),
            ),
            body: Text(
              'Loading...',
              style: theme.textTheme.labelMedium,
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('NoteBash'),
              actions: <Widget>[
                PopupMenuButton(
                  icon: const Icon(Icons.menu),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.import_export),
                          title: const Text('Export Database'),
                          onTap: () async => await _exportDatabase(),
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(db: widget._db),
                              ),
                            );
                          },
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotePage(
                          userId: widget.userId,
                          note: _notes[index],
                          db: widget._db,
                        ),
                      ),
                    ).then((value) async {
                      await _refreshNotes();
                      setState(() {});
                    });
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(_notes[index].description),
                      subtitle: Text(
                          DateFormat.yMMMd().format(_notes[index].dateCreated)),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showOptions(context);
              },
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        }
      },
    );
  }
}
