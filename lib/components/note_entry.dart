import 'package:flutter/material.dart';
import 'package:notebash_app/models/note.dart';
import 'package:notebash_app/services/note_service.dart';
import 'package:sqflite/sqflite.dart';

class NoteEntry extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final Note? note;

  const NoteEntry({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.note,
  });

  @override
  State<NoteEntry> createState() => _NoteEntryState();
}

class _NoteEntryState extends State<NoteEntry> {
  late NoteService _service;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _service = NoteService(db: widget.db);
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  Future<void> _saveNote() async {
    final note = Note(
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      color: '#000000',
      dateCreated: DateTime.now(),
    );
    await _service.add(note);
    widget.onSave();
    _close();
    _showSnackBar('Note has been added');
  }

  Future<void> _updateNote() async {
    if (widget.note != null) {
      final note = Note(
        id: widget.note!.id,
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        color: '#000000',
        dateCreated: DateTime.now(),
      );
      await _service.update(note);
      widget.onSave();
      _close();
      _showSnackBar('Note has been updated');
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note != null) {
      await _service.delete(widget.note!.id!);
      widget.onSave();
      _close();
      _showSnackBar('Note has been deleted');
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
    return Padding(
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
                "Description",
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Enter description',
                contentPadding: const EdgeInsets.all(12),
                fillColor: theme.inputDecorationTheme.fillColor,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 40.0),
            TextButton(
              onPressed: () =>
                  widget.note != null ? _updateNote() : _saveNote(),
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Save Note',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            if (widget.note != null)
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                onPressed: () => _deleteNote(),
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Delete Note',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (widget.note != null) const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
