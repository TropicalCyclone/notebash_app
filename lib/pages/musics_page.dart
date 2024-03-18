import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/music_actions.dart';
import 'package:notebash_app/components/music_item.dart';
import 'package:notebash_app/models/music.dart';
import 'package:notebash_app/pages/music_entry_page.dart';
import 'package:notebash_app/services/music_service.dart';
import 'package:notebash_app/utils/helpers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MusicsPage extends StatefulWidget {
  final int userId;
  final Database _db;

  const MusicsPage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<MusicsPage> createState() => _MusicsPageState();
}

class _MusicsPageState extends State<MusicsPage> {
  List<Music> _musics = [];
  late MusicService _service;

  @override
  void initState() {
    super.initState();
    _musics = [];
    _service = MusicService(db: widget._db);
  }

  Future<void> _load() async {
    var musics = await _service.getByUserId(widget.userId);
    _musics = musics;
  }

  Future<void> _exportMusics() async {
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
            context, 'File exported successfully to $folder\\musics.json');
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
      if (mounted) showSnackBar(context, 'Musics imported successfully');
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
      builder: (context) => MusicActions(
        musicEntryPage: MusicEntryPage(
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
                      "assets/images/music.svg",
                      semanticsLabel: "Musics",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Musics'),
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
                      "assets/images/music.svg",
                      semanticsLabel: "Musics",
                      colorFilter: ColorFilter.mode(
                        Colors.grey[700]!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  const Text('Musics'),
                ],
              ),
              leading: IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.chevron_left),
              ),
              actions: [
                IconButton(
                  onPressed: _musics.isEmpty ? null : () => _exportMusics(),
                  icon: const Icon(Icons.upload),
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: ListView.separated(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(10),
              itemCount: _musics.length,
              itemBuilder: (context, index) => MusicItem(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicEntryPage(
                      userId: widget.userId,
                      db: widget._db,
                      music: _musics[index],
                      onSave: () async {
                        await _load();
                        setState(() {});
                      },
                    ),
                  ),
                ),
                music: _musics[index],
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
