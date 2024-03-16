import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/note_color.dart';
import 'package:notebash_app/models/note.dart';
import 'package:notebash_app/services/note_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NoteEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final Note? note;

  const NoteEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.note,
  });

  @override
  State<NoteEntryPage> createState() => _NoteEntryPageState();
}

class _NoteEntryPageState extends State<NoteEntryPage> {
  late NoteService _service;
  int? _selectedColor;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _errorMessage = '';

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

    _selectedColor = widget.note?.color;
    _errorMessage = '';
  }

  void _onColorChanged(int color) {
    _selectedColor = color;
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Title and description are required';
      });
      return;
    }

    final note = Note(
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      color: _selectedColor ?? 0XFFDFE2EB,
      dateCreated: DateTime.now(),
    );
    await _service.add(note);
    widget.onSave();
    _close();
    _showSnackBar('Note has been added');
  }

  Future<void> _updateNote() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Title and description are required';
      });
      return;
    }

    if (widget.note != null) {
      final note = Note(
        id: widget.note!.id,
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        color: _selectedColor ?? 0XFFDFE2EB,
        dateCreated: DateTime.now(),
      );
      await _service.update(note);
      widget.onSave();
      _close();
      _showSnackBar('Note has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
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
              onPressed: () => _deleteNote(),
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

  Future<void> _deleteNote() async {
    _close();

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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              child: SvgPicture.asset(
                "assets/images/pen.svg",
                semanticsLabel: "Pen Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.note == null ? 'New Note' : 'Edit Note'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.note == null
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
                child: NoteColor(
                    selectedColor: widget.note?.color,
                    onColorChanged: _onColorChanged),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () =>
                      widget.note != null ? _updateNote() : _saveNote(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Note',
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
