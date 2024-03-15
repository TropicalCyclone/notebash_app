import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notebash_app/services/db_initializer.dart';
import 'pages/login_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Database? db;

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();

  db = await initDb();
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
    LoginPage page = LoginPage(db: db!);

    return MaterialApp(
      title: 'Login/Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: page,
    );
  }
}
