import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/task_actions.dart';
import 'package:notebash_app/components/task_item.dart';
import 'package:notebash_app/models/task.dart';
import 'package:notebash_app/pages/task_entry_page.dart';
import 'package:notebash_app/services/task_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TasksPage extends StatefulWidget {
  final int userId;
  final Database _db;

  const TasksPage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late TaskService _service;
  List<Task> _unfinished = [];
  List<Task> _finished = [];
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _unfinished = [];
    _service = TaskService(db: widget._db);
  }

  Future<void> _load() async {
    var tasks = await _service.getByUserId(widget.userId);
    _unfinished = tasks.where((task) => task.isDone == false).toList();
    _finished = tasks.where((task) => task.isDone == true).toList();
  }

  Future<void> _exportTasks() async {
    if (!await tryGrantPermission()) {
      if (mounted) showSnackBar(context, "Access denied", error: true);
      return;
    }

    String? folder = await FilePicker.platform.getDirectoryPath();

    if (folder == null) return;

    final result = await _service.export(widget.userId, folder);

    if (result.success) {
      if (mounted) {
        showSnackBar(
            context, 'File exported successfully to $folder\\tasks.json');
      }
    } else {
      if (mounted) showSnackBar(context, result.message!, error: true);
    }
  }

  Future<void> _onImport(String contents) async {
    final result = await _service.import(contents);
    if (result.success) {
      await _load();
      setState(() {});
      if (mounted) showSnackBar(context, 'Tasks imported successfully');
    } else {
      if (mounted) showSnackBar(context, result.message!, error: true);
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(15),
          topStart: Radius.circular(15),
        ),
      ),
      builder: (context) => TaskActions(
        taskEntryPage: TaskEntryPage(
            userId: widget.userId,
            db: widget._db,
            onSave: () async {
              await _load();
              setState(() {});
            }),
        onImport: (contents) => _onImport(contents),
      ),
    );
  }

  Future<void> _onStatusChanged(Task task, bool isDone) async {
    task.isDone = isDone;
    await _service.update(task);
    await _load();
    setState(() {});
  }

  List<Widget> loadTasks(BuildContext context, List<Task> tasks) {
    final items = <Widget>[];

    for (var i = 0; i < tasks.length; i++) {
      items.add(TaskItem(
        onStatusChanged: (task, isDone) async =>
            await _onStatusChanged(task, isDone),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskEntryPage(
              userId: widget.userId,
              db: widget._db,
              task: tasks[i],
              onSave: () async {
                await _load();
                setState(() {});
              },
            ),
          ),
        ),
        task: tasks[i],
      ));

      if (i < tasks.length - 1) {
        items.add(const SizedBox(height: 10));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expandableController =
        ExpandableController(initialExpanded: _isExpanded);

    expandableController.addListener(() {
      _isExpanded = expandableController.expanded;
    });

    return FutureBuilder<void>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  SizedBox(
                    child: SvgPicture.asset(
                      "assets/images/task.svg",
                      semanticsLabel: "Tasks",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Tasks'),
                ],
              ),
            ),
            body: Text(
              'Loading...',
              style: theme.textTheme.labelMedium,
            ),
          );
        } else {
          return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    SizedBox(
                      child: SvgPicture.asset(
                        "assets/images/task.svg",
                        semanticsLabel: "Tasks",
                        colorFilter: ColorFilter.mode(
                          Colors.grey[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    const Text('Tasks'),
                  ],
                ),
                leading: IconButton(
                  onPressed: () => {Navigator.pop(context)},
                  icon: const Icon(Icons.chevron_left),
                ),
                actions: [
                  IconButton(
                    onPressed: _unfinished.isEmpty && _finished.isEmpty
                        ? null
                        : () => _exportTasks(),
                    icon: const Icon(Icons.upload),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              body: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Column(children: loadTasks(context, _unfinished)),
                    if (_finished.isNotEmpty) const SizedBox(height: 10),
                    if (_finished.isNotEmpty)
                      ExpandableNotifier(
                        controller: expandableController,
                        child: ScrollOnExpand(
                          scrollOnCollapse: true,
                          scrollOnExpand: true,
                          child: ExpandablePanel(
                            header:
                                const ListTile(title: Text("Finished tasks")),
                            collapsed: const SizedBox(width: 0),
                            expanded: Column(children: [
                              const SizedBox(height: 10),
                              ...loadTasks(context, _finished)
                            ]),
                            theme: const ExpandableThemeData(
                              useInkWell: true,
                              headerAlignment:
                                  ExpandablePanelHeaderAlignment.center,
                              inkWellBorderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )),
              floatingActionButton: FloatingActionButton(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: const CircleBorder(),
                onPressed: () => _showOptions(context),
                child: const Icon(Icons.add),
              ));
        }
      },
    );
  }
}
