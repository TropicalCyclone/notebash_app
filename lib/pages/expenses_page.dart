import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:notebash_app/components/expense_actions.dart';
import 'package:notebash_app/components/expense_item.dart';
import 'package:notebash_app/models/expense.dart';
import 'package:notebash_app/pages/expense_entry_page.dart';
import 'package:notebash_app/services/expense_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ExpensesPage extends StatefulWidget {
  final int userId;
  final Database _db;

  const ExpensesPage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late ExpenseService _service;
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _service = ExpenseService(db: widget._db);
  }

  Future<void> _load() async {
    _expenses = await _service.getByUserId(widget.userId);
  }

  Future<void> _exportExpenses() async {
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
            context, 'File exported successfully to $folder\\expenses.json');
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
      if (mounted) showSnackBar(context, 'Expenses imported successfully');
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
      builder: (context) => ExpenseActions(
        taskEntryPage: ExpenseEntryPage(
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

  List<Widget> loadExpenses(BuildContext context, List<Expense> tasks) {
    final items = <Widget>[];

    for (var i = 0; i < tasks.length; i++) {
      items.add(ExpenseItem(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseEntryPage(
              userId: widget.userId,
              db: widget._db,
              expense: tasks[i],
              onSave: () async {
                await _load();
                setState(() {});
              },
            ),
          ),
        ),
        expense: tasks[i],
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
                      "assets/images/coins.svg",
                      semanticsLabel: "Coins Icon",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Expenses'),
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
                        "assets/images/coins.svg",
                        semanticsLabel: "Coins Icon",
                        colorFilter: ColorFilter.mode(
                          Colors.grey[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    const Text('Expenses'),
                  ],
                ),
                leading: IconButton(
                  onPressed: () => {Navigator.pop(context)},
                  icon: const Icon(Icons.chevron_left),
                ),
                actions: [
                  IconButton(
                    onPressed:
                        _expenses.isEmpty ? null : () => _exportExpenses(),
                    icon: const Icon(Icons.upload),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: groupItems(),
                  ),
                ),
              ),
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

  List<Widget> groupItems() {
    List<Widget> group = [];
    List<Widget> subItems = [];

    DateTime? currentDate;

    int count = 0;
    for (var exp in _expenses) {
      if (currentDate == null || currentDate != exp.date) {
        if (group.isNotEmpty) {
          group.add(const SizedBox(height: 10));
        }

        if (subItems.isNotEmpty) {
          group.add(_buildExpandablePanel(currentDate!, subItems));
          subItems = [];
        }
      }

      subItems.add(const SizedBox(height: 10));
      subItems.add(
        ExpenseItem(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseEntryPage(
                userId: widget.userId,
                db: widget._db,
                expense: exp,
                onSave: () async {
                  await _load();
                  setState(() {});
                },
              ),
            ),
          ),
          expense: exp,
        ),
      );

      count++;

      if (count >= _expenses.length) {
        if (group.isNotEmpty) {
          group.add(const SizedBox(height: 10));
        }
        group.add(_buildExpandablePanel(exp.date, subItems));
      }
      currentDate = exp.date;
    }
    return group;
  }

  ExpandableNotifier _buildExpandablePanel(
      DateTime date, List<Widget> subItems) {
    return ExpandableNotifier(
      controller: ExpandableController(initialExpanded: true),
      child: ScrollOnExpand(
        scrollOnCollapse: true,
        scrollOnExpand: true,
        child: ExpandablePanel(
          header: ListTile(
            title: Row(
              children: [
                Expanded(child: Text(_formatDay(date))),
                Text(
                  formatAmount(
                    _expenses
                        .where((x) => x.date == date)
                        .map((e) => e.amount)
                        .reduce((v, e) => v + e),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          collapsed: const SizedBox(width: 0),
          expanded: Column(
            children: subItems,
          ),
          theme: const ExpandableThemeData(
            useInkWell: true,
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            inkWellBorderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    return DateFormat('EE MMM dd, yyyy').format(date);
  }
}
