import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/LoginPage.dart';
import 'package:notebash_app/NotesDatabase.dart';
import 'package:notebash_app/NoteEditScreen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Note> notes;
  final dbHelper = NotesDatabase();
  String? _selectedDirectoryPath;

  @override
  void initState() {
    super.initState();
    notes = [];
    refreshNotes();
  }

  void refreshNotes() async {
    List<Note> _notes = await dbHelper.getNotesByUserId(widget.userId);
    setState(() {
      notes = _notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NoteBash'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.menu),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.folder_open),
                    title: Text('Select Export Folder'),
                    onTap: _selectDestinationFolder,
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.import_export),
                    title: Text('Export Database'),
                    onTap: () {
                      if (_selectedDirectoryPath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a destination folder first.'),
                          ),
                        );
                      } else {
                        _exportDatabase();
                      }
                    },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
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
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditScreen(userId: widget.userId, note: notes[index], isUpdating: true),
                ),
              ).then((value) => refreshNotes());
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(notes[index].title),
                subtitle: Text('${notes[index].dateCreated.toString()}'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOptions(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                  leading: new Icon(Icons.note),
                  title: new Text('Create New Note'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteEditScreen(userId: widget.userId, isUpdating: false,),
                      ),
                    ).then((value) => refreshNotes());
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.import_export),
                  title: new Text('Import Note'),
                  onTap: () {
                    Navigator.pop(context);
                    _importNote();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _importNote() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String contents = await file.readAsString();
      await dbHelper.importNotes(contents);
      refreshNotes();
    }
  }

  void _selectDestinationFolder() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _selectedDirectoryPath = directoryPath;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Destination folder selected: $directoryPath'),
        ),
      );
    }
  }

  void _exportDatabase() async {
    if (_selectedDirectoryPath != null) {
      String filePath = await dbHelper.exportNotes(widget.userId);
      File exportFile = File(filePath);
      if (exportFile.existsSync()) {
        // Generate unique file name using current date and time
        DateTime now = DateTime.now();
        String formattedDate = '${now.minute}_${now.hour}_${now.day}_${now.month}_${now.year}';
        String newFileName = 'notes_export_$formattedDate.json';

        // Construct the new file path
        String newFilePath = path.join(_selectedDirectoryPath!, newFileName);

        // Copy the file to the chosen directory with the new file name
        await exportFile.copy(newFilePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported successfully to $newFilePath'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting file.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a destination folder first.'),
        ),
      );
    }
  }
}


