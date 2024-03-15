import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/home_page.dart';
import 'package:notebash_app/services/db_initializer.dart';
import 'package:notebash_app/services/log_service.dart';
import 'pages/login_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Database? db;
Widget? startPage;

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();

  db = await initDb();
  final logService = LogService(db: db!);
  final log = await logService.get();

  if (log != null) {
    startPage = HomePage(db: db!, userId: log.userId);
  } else {
    startPage = LoginPage(db: db!);
  }

  runApp(const NoteBashApp());
}

class NoteBashApp extends StatefulWidget {
  const NoteBashApp({super.key});

  @override
  State<NoteBashApp> createState() => _NoteBashAppState();
}

class _NoteBashAppState extends State<NoteBashApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteBash',
      theme: ThemeData(
              fontFamily: "Plus Jakarta Sans",
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true)
          .copyWith(
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
        ),
      ),
      home: startPage!,
    );
  }
}
