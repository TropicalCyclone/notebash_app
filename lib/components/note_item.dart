import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notebash_app/models/note.dart';

class NoteItem extends StatelessWidget {
  final void Function() onTap;
  final Note note;

  const NoteItem({super.key, required this.onTap, required this.note});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(note.color),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(note.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Text(_formatTime(note.dateCreated),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Text(note.description,
                  style: Theme.of(context).textTheme.bodyMedium!),
              const SizedBox(height: 10),
              Text(_formatDay(note.dateCreated),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDay(DateTime date) {
  return DateFormat('EE MMM dd, yyyy').format(date);
}

String _formatTime(DateTime date) {
  return DateFormat('jm').format(date);
}
