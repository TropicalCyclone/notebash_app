import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/music_entry_page.dart';

class MusicActions extends StatefulWidget {
  final MusicEntryPage musicEntryPage;
  final void Function(String) onImport;

  const MusicActions({
    super.key,
    required this.onImport,
    required this.musicEntryPage,
  });

  @override
  State<MusicActions> createState() => _MusicActionsState();
}

class _MusicActionsState extends State<MusicActions> {
  Future<void> _importMusic() async {
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
          child: Text(
            'Music Actions',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
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
                            builder: (context) => widget.musicEntryPage));
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Create New Music',
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
                      await _importMusic();
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
                      'Import Musics',
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
