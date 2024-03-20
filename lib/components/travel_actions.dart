import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/travel_entry_page.dart';

class TravelActions extends StatefulWidget {
  final TravelEntryPage travelEntryPage;
  final void Function(String) onImport;

  const TravelActions({
    super.key,
    required this.onImport,
    required this.travelEntryPage,
  });

  @override
  State<TravelActions> createState() => _TravelActionsState();
}

class _TravelActionsState extends State<TravelActions> {
  Future<void> _importTravel() async {
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
              'Travel  Actions',
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
                            builder: (context) => widget.travelEntryPage));
                  },
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Create New Destination',
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
                      await _importTravel();
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
                      'Import Travels',
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
