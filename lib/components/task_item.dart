import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notebash_app/models/task.dart';

class TaskItem extends StatelessWidget {
  final void Function() onTap;
  final Task task;
  final void Function(Task, bool) onStatusChanged;

  const TaskItem(
      {super.key,
      required this.onTap,
      required this.task,
      required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).hoverColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: task.isDone ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (checked) => onStatusChanged(task, checked ?? false),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                    if (task.isDone) const SizedBox(height: 10),
                    if (task.isDone)
                      Text(
                        _formatDay(task.dateCreated),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
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
