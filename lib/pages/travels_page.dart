import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/travel_actions.dart';
import 'package:notebash_app/components/travel_item.dart';
import 'package:notebash_app/models/travel.dart';
import 'package:notebash_app/pages/travel_entry_page.dart';
import 'package:notebash_app/services/travel_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TravelsPage extends StatefulWidget {
  final int userId;
  final Database _db;

  const TravelsPage({super.key, required this.userId, required Database db})
      : _db = db;

  @override
  State<TravelsPage> createState() => _TravelsPageState();
}

class _TravelsPageState extends State<TravelsPage> {
  List<Travel> _travels = [];
  late TravelService _service;

  @override
  void initState() {
    super.initState();
    _travels = [];
    _service = TravelService(db: widget._db);
  }

  Future<void> _load() async {
    var travels = await _service.getByUserId(widget.userId);
    _travels = travels;
  }

  Future<void> _exportTravels() async {
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
            context, 'File exported successfully to $folder\\travels.json');
      }
    } else {
      if (mounted) showSnackBar(context, result.message!, error: true);
    }
  }

  Future<void> onImport(String contents) async {
    final result = await _service.import(contents);
    if (result.success) {
      await _load();
      setState(() {});
      if (mounted) showSnackBar(context, 'Travels imported successfully');
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
      builder: (context) => TravelActions(
        travelEntryPage: TravelEntryPage(
            userId: widget.userId,
            db: widget._db,
            onSave: () async {
              await _load();
              setState(() {});
            }),
        onImport: (contents) => onImport(contents),
      ),
    );
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
                      "assets/images/plane.svg",
                      semanticsLabel: "Plane Icon",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Travel Destinations'),
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
                      "assets/images/plane.svg",
                      semanticsLabel: "Plane Icon",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Travel Destinations'),
                ],
              ),
              leading: IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.chevron_left),
              ),
              actions: [
                IconButton(
                  onPressed: _travels.isEmpty ? null : () => _exportTravels(),
                  icon: const Icon(Icons.upload),
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: _travels.length,
              itemBuilder: (context, index) => TravelItem(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TravelEntryPage(
                      userId: widget.userId,
                      db: widget._db,
                      travel: _travels[index],
                      onSave: () async {
                        await _load();
                        setState(() {});
                      },
                    ),
                  ),
                ),
                travel: _travels[index],
              ),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              onPressed: () => _showOptions(context),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
