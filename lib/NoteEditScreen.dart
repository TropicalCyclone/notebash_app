import 'package:flutter/material.dart';
import 'package:notebash_app/NotesDatabase.dart';

class NoteEditScreen extends StatefulWidget {
  final int userId;
  final Note? note;
  final bool isUpdating;

  NoteEditScreen({required this.userId, this.note, required this.isUpdating});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          title: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter title',
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
            ),
          ),
          actions: [
            if (widget.isUpdating)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.0),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
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
          if (widget.isUpdating) {
            _updateNote();
          } else {
            _saveNote();
          }
        },
        child: Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _saveNote() {
    // Save note
    final newNote = Note(
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      dateCreated: DateTime.now(),
    );
    NotesDatabase().insertNote(newNote);
    Navigator.pop(context);
  }

  void _updateNote() {
    if (widget.note != null) {
      //print("updated note");
      final updatedNote = Note(
        id: widget.note!.id,
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        dateCreated: DateTime.now(),
      );
      NotesDatabase().updateNote(updatedNote);
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNoteAndNavigateBack();
              },
              child: Text(
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
      await NotesDatabase().deleteNote(widget.note!);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
