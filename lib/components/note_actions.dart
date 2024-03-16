import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/note_entry_page.dart';

class NoteActions extends StatefulWidget {
  final NoteEntryPage noteEntryPage;
  final void Function(String) onImport;
  const NoteActions({
    super.key,
    required this.noteEntryPage,
    required this.onImport,
  });

  @override
  State<NoteActions> createState() => _NoteActionsState();
}

class _NoteActionsState extends State<NoteActions> {
  Future<void> _importNote() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (fileResult != null) {
      final file = File(fileResult.files.single.path!);
      final contents = await file.readAsString();

      widget.onImport(contents);
    }
  }

  void _popNavigation() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
        Center(
          child: Center(
            child: Text(
              'Quick Notes Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () {
                    _popNavigation();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => widget.noteEntryPage));
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Create New Note',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                    onPressed: () async {
                      await _importNote();
                      _popNavigation();
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Import Notes',
                    )),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        )
      ],
    );
  }
}
