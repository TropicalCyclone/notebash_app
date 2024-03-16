import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:notebash_app/components/note_entry.dart';
import 'package:notebash_app/models/note.dart';
import 'package:notebash_app/services/note_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NotesPage extends StatefulWidget {
  final int userId;
  final Database _db;

  const NotesPage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  late NoteService _service;

  @override
  void initState() {
    super.initState();
    _notes = [];
    _service = NoteService(db: widget._db);
  }

  Future<void> _load() async {
    var notes = await _service.getByUserId(widget.userId);
    _notes = notes;
  }

  Future<void> _exportNotes() async {
    String? folder = await FilePicker.platform.getDirectoryPath();

    if (folder == null) return;

    final result = await _service.export(widget.userId, folder);

    if (result.success) {
      _showSnackBar('File exported successfully to $folder/notes.json');
    } else {
      _showSnackBar(result.message!);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
        await _load();
        _showSnackBar('Notes imported successfully');
      } else {
        _showSnackBar(result.message!);
      }
    }
  }

  void _popNavigation() {
    Navigator.pop(context);
  }

  void _showOptions(BuildContext context, [bool edit = false, Note? note]) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(15),
          topStart: Radius.circular(15),
        ),
      ),
      builder: (context) => Wrap(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 6,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      edit ? 'Update Note' : 'Add Note',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              if (!edit)
                Positioned(
                  right: 20,
                  top: 0,
                  height: 40,
                  width: 40,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: () async {
                        await _importNote();
                        _popNavigation();
                        setState(() {});
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ),
                )
            ],
          ),
          NoteEntry(
            db: widget._db,
            userId: widget.userId,
            note: note,
            onSave: () async {
              await _load();
              setState(() {});
            },
          ),
        ],
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
                      "assets/images/pen.svg",
                      semanticsLabel: "Quick Notes",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Quick Notes'),
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
                        "assets/images/pen.svg",
                        semanticsLabel: "Quick Notes",
                        colorFilter: ColorFilter.mode(
                          Colors.grey[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    const Text('Quick Notes'),
                  ],
                ),
                leading: IconButton(
                  onPressed: () => {Navigator.pop(context)},
                  icon: const Icon(Icons.chevron_left),
                ),
                actions: [
                  IconButton(
                    onPressed: _notes.isEmpty ? null : () => _exportNotes(),
                    icon: const Icon(Icons.upload),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              body: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showOptions(context, true, _notes[index]),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(_notes[index].description),
                        subtitle: Text(DateFormat.yMMMd()
                            .format(_notes[index].dateCreated)),
                      ),
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: const CircleBorder(),
                onPressed: () => _showOptions(context),
                child: const Icon(Icons.add),
              ));
        }
      },
    );
  }
}
