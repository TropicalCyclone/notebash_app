import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/models/task.dart' as model;
import 'package:notebash_app/services/task_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TaskEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final model.Task? task;

  const TaskEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.task,
  });

  @override
  State<TaskEntryPage> createState() => _TaskEntryPageState();
}

class _TaskEntryPageState extends State<TaskEntryPage> {
  late TaskService _service;
  final TextEditingController _nameController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _service = TaskService(db: widget.db);
    if (widget.task != null) {
      _nameController.text = widget.task!.name;
    } else {
      _nameController.clear();
    }

    _errorMessage = '';
  }

  Future<void> _saveNote() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Name is required';
      });
      return;
    }

    final task = model.Task(
      userId: widget.userId,
      name: _nameController.text,
      dateCreated: DateTime.now(),
    );
    await _service.add(task);
    widget.onSave();
    _close();
    _showSnackBar('Task has been added');
  }

  Future<void> _updateNote() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Name is required';
      });
      return;
    }

    if (widget.task != null) {
      final note = model.Task(
        id: widget.task!.id,
        userId: widget.userId,
        name: _nameController.text,
        dateCreated: DateTime.now(),
      );
      await _service.update(note);
      widget.onSave();
      _close();
      _showSnackBar('Task has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
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

    if (widget.task != null) {
      await _service.delete(widget.task!.id!);
      widget.onSave();
      _close();
      _showSnackBar('Task has been deleted');
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
                "assets/images/task.svg",
                semanticsLabel: "Task Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.task == null ? 'New Task' : 'Edit Task'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.task == null
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
                  "Name",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter task',
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
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () =>
                      widget.task != null ? _updateNote() : _saveNote(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Task',
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
