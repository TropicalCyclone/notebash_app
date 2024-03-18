import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/models/book.dart';
import 'package:notebash_app/services/book_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BookEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final Book? book;

  const BookEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.book,
  });

  @override
  State<BookEntryPage> createState() => _BookEntryPageState();
}

class _BookEntryPageState extends State<BookEntryPage> {
  late BookService _service;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();

  String _errorMessage = '';
  String _yearError = '';

  @override
  void initState() {
    super.initState();

    _service = BookService(db: widget.db);
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _yearController.text = widget.book!.yearPublished.toString();
      _authorsController.text = widget.book!.authors;
    } else {
      _titleController.clear();
      _yearController.clear();
      _authorsController.clear();
    }

    _errorMessage = '';
    _yearError = '';
  }

  Future<void> _saveBook() async {
    if (!validateEntries()) return;

    final book = Book(
      userId: widget.userId,
      title: _titleController.text,
      authors: _authorsController.text,
      yearPublished: int.parse(_yearController.text),
    );
    await _service.add(book);
    widget.onSave();
    _close();
    _showSnackBar('Book has been added');
  }

  bool validateEntries() {
    if (int.tryParse(_yearController.text) == null) {
      setState(() {
        _yearError = 'Invalid value';
      });
      return false;
    }

    if (_titleController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _authorsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return false;
    }

    return true;
  }

  Future<void> _updateBook() async {
    if (!validateEntries()) return;

    if (widget.book != null) {
      final book = Book(
        id: widget.book!.id,
        userId: widget.userId,
        title: _titleController.text,
        authors: _authorsController.text,
        yearPublished: int.parse(_yearController.text),
      );
      await _service.update(book);
      widget.onSave();
      _close();
      _showSnackBar('Book has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: const Text('Are you sure you want to delete this book?'),
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
              onPressed: () => _deleteBook(),
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

  Future<void> _deleteBook() async {
    _close();

    if (widget.book != null) {
      await _service.delete(widget.book!.id!);
      widget.onSave();
      _close();
      _showSnackBar('Book has been deleted');
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
                "assets/images/book.svg",
                semanticsLabel: "Book Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(widget.book == null ? 'New Book' : 'Edit Book'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.book == null
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
                  "Title",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter title',
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
                  "Authors",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _authorsController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter authors',
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
                  "Year Published",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _yearController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter publication year',
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
              if (_yearError.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _yearError,
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
                  onPressed: () =>
                      widget.book != null ? _updateBook() : _saveBook(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Book',
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
