import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/models/travel.dart' as model;
import 'package:notebash_app/services/travel_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TravelEntryPage extends StatefulWidget {
  final int userId;
  final VoidCallback onSave;
  final Database db;
  final model.Travel? travel;

  const TravelEntryPage({
    super.key,
    required this.db,
    required this.userId,
    required this.onSave,
    this.travel,
  });

  @override
  State<TravelEntryPage> createState() => _TravelEntryPageState();
}

class _TravelEntryPageState extends State<TravelEntryPage> {
  late TravelService _service;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _travelDateController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _service = TravelService(db: widget.db);
    if (widget.travel != null) {
      _destinationController.text = widget.travel!.destination;
      _travelDateController.text =
          widget.travel!.travelDate.toString().split(" ")[0];
    } else {
      _destinationController.clear();
    }

    _errorMessage = '';
  }

  Future<void> _saveTravel() async {
    if (_destinationController.text.isEmpty ||
        _travelDateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    final travel = model.Travel(
        userId: widget.userId,
        destination: _destinationController.text,
        travelDate: DateTime.parse(_travelDateController.text));
    await _service.add(travel);
    widget.onSave();
    _close();
    if (mounted) showSnackBar(context, 'Travel destination has been added');
  }

  Future<void> _updateTravel() async {
    if (_destinationController.text.isEmpty ||
        _travelDateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (widget.travel != null) {
      final travel = model.Travel(
          id: widget.travel!.id,
          userId: widget.userId,
          destination: _destinationController.text,
          travelDate: DateTime.parse(_travelDateController.text));
      await _service.update(travel);
      widget.onSave();
      _close();
      if (mounted) showSnackBar(context, 'Travel destination has been updated');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Destination'),
          content: const Text(
              'Are you sure you want to delete this travel destination?'),
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
              onPressed: () => _deleteTravel(),
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

  Future<void> _deleteTravel() async {
    _close();

    if (widget.travel != null) {
      await _service.delete(widget.travel!.id!);
      widget.onSave();
      _close();
      if (mounted) showSnackBar(context, 'Travel destination has been deleted');
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
      initialDate:
          DateTime.tryParse(_travelDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2020, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _travelDateController.text = picked.toString().split(" ")[0];
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
                "assets/images/plane.svg",
                semanticsLabel: "Plane Icon",
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(
                widget.travel == null ? 'New Destination' : 'Edit Destination'),
          ],
        ),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
        actions: widget.travel == null
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
                  "Destination",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter destination',
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
                  "Travel Date",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                onTap: () => _selectDate(),
                readOnly: true,
                mouseCursor: SystemMouseCursors.click,
                controller: _travelDateController,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today, size: 20),
                  hintText: 'Enter travel date',
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
                      widget.travel != null ? _updateTravel() : _saveTravel(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Save Destination',
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
