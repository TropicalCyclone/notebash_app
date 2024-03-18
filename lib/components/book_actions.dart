import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/book_entry_page.dart';

class BookActions extends StatefulWidget {
  final BookEntryPage bookEntryPage;
  final void Function(String) onImport;

  const BookActions({
    super.key,
    required this.onImport,
    required this.bookEntryPage,
  });

  @override
  State<BookActions> createState() => _BookActionsState();
}

class _BookActionsState extends State<BookActions> {
  Future<void> _importBook() async {
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
              'Book Actions',
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
                            builder: (context) => widget.bookEntryPage));
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Create New Book',
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
                      await _importBook();
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
                      'Import Books',
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
