import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/models/expense.dart';
import 'package:notebash_app/services/expense_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ExpenseEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final Expense? expense;

  const ExpenseEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.expense,
  });

  @override
  State<ExpenseEntryPage> createState() => _ExpenseEntryPageState();
}

class _ExpenseEntryPageState extends State<ExpenseEntryPage> {
  late ExpenseService _service;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _errorMessage = '';
  String _amountError = "";

  @override
  void initState() {
    super.initState();

    _service = ExpenseService(db: widget.db);
    _dateController.text = DateTime.now().toString().split(" ")[0];

    if (widget.expense != null) {
      _dateController.text = widget.expense!.date.toString().split(" ")[0];
      _categoryController.text = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toString();
    } else {
      _categoryController.clear();
    }

    _errorMessage = '';
    _amountError = "";
  }

  Future<void> _saveExpense() async {
    if (_categoryController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _amountController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (double.tryParse(_amountController.text) == null) {
      setState(() {
        _errorMessage = 'Amount must be a number';
      });
      return;
    }

    final expense = Expense(
        userId: widget.userId,
        category: _categoryController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.parse(_dateController.text));

    await _service.add(expense);
    widget.onSave();
    _close();
    if (mounted) showSnackBar(context, 'Expense expense has been added');
  }

  Future<void> _updateExpense() async {
    if (_categoryController.text.isEmpty || _dateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (widget.expense != null) {
      final expense = Expense(
          id: widget.expense!.id,
          userId: widget.userId,
          category: _categoryController.text,
          amount: double.parse(_amountController.text),
          date: DateTime.parse(_dateController.text));
      await _service.update(expense);
      widget.onSave();
      _close();
      if (mounted) {
        showSnackBar(context, 'Expense destination has been updated');
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Destination'),
          content: const Text(
              'Are you sure you want to delete this expense destination?'),
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
              onPressed: () => _deleteExpense(),
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

  Future<void> _deleteExpense() async {
    _close();

    if (widget.expense != null) {
      await _service.delete(widget.expense!.id!);
      widget.onSave();
      _close();
      if (mounted) {
        showSnackBar(context, 'Expense destination has been deleted');
      }
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showRoundedDatePicker(
      context: context,
      height: 350,
      theme: Theme.of(context),
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2020, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
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
                "assets/images/coins.svg",
                semanticsLabel: "Coins Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.expense == null ? 'New Expense' : 'Edit Expense'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.expense == null
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
                  "Date",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                onTap: () => _selectDate(),
                readOnly: true,
                mouseCursor: SystemMouseCursors.click,
                controller: _dateController,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today, size: 20),
                  hintText: 'Enter date',
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
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Category",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'E.g Food, Transport, etc.',
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
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Amount",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter amount',
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
              if (_amountError.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _amountError,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => widget.expense != null
                      ? _updateExpense()
                      : _saveExpense(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Expense',
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
