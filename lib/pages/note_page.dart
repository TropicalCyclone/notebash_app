import 'package:flutter/material.dart';
import 'package:notebash_app/models/note.dart';
import 'package:notebash_app/services/note_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NoteEditScreen extends StatefulWidget {
  final int userId;
  final Note? note;
  final Database _db;

  const NoteEditScreen(
      {super.key, required this.userId, this.note, required Database db})
      : _db = db;

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late NoteService _service;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');

    _service = NoteService(db: widget._db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Enter title',
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8.0),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Note',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.note != null) {
            _updateNote();
          } else {
            _saveNote();
          }
        },
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _saveNote() {
    final note = Note(
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      color: '#000000',
      dateCreated: DateTime.now(),
    );
    _service.add(note);
    Navigator.pop(context);
  }

  void _updateNote() {
    if (widget.note != null) {
      final note = Note(
        id: widget.note!.id,
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        color: '#000000',
        dateCreated: DateTime.now(),
      );
      _service.update(note);
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNoteAndNavigateBack();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNoteAndNavigateBack() async {
    if (widget.note != null) {
      await _service.delete(widget.note!.id!);
      Navigator.pop(context);
    }
  }
}
