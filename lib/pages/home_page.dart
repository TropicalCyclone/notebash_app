import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/components/home_icon.dart';
import 'package:flutter/material.dart';
import 'package:notebash_app/pages/books_page.dart';
import 'package:notebash_app/pages/expenses_page.dart';
import 'package:notebash_app/pages/login_page.dart';
import 'package:notebash_app/pages/movies_page.dart';
import 'package:notebash_app/pages/musics_page.dart';
import 'package:notebash_app/pages/notes_page.dart';
import 'package:notebash_app/pages/recipes_page.dart';
import 'package:notebash_app/pages/tasks_page.dart';
import 'package:notebash_app/pages/travels_page.dart';
import 'package:notebash_app/services/log_service.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final Database _db;

  const HomePage({super.key, required this.userId, required db}) : _db = db;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LogService _service;

  @override
  void initState() {
    super.initState();
    _service = LogService(db: widget._db);
  }

  Future<void> _logOutCurrentUser() async {
    await _service.delete(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void backToLogin() {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(db: widget._db),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 50.0),
                SizedBox(
                  child: SvgPicture.asset("assets/images/bash.svg",
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: "Logo"),
                ),
                const SizedBox(width: 5.0),
                Text(
                  'NoteBash',
                  style: theme.textTheme.titleLarge!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                backToLogin();
                await _logOutCurrentUser();
              },
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 10),
          ]),
      body: GridView.count(
        padding: const EdgeInsets.all(14),
        crossAxisCount: 2,
        childAspectRatio: 0.90,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          HomeIcon(
            color: Colors.blue[400],
            icon: "assets/images/pen.svg",
            label: "Quick Notes",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotesPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: Colors.blue[500],
            icon: "assets/images/task.svg",
            label: "Tasks",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TasksPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: Colors.blue[600],
            icon: "assets/images/clapper.svg",
            label: "Movies",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoviesPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: Colors.blue[700],
            icon: "assets/images/book.svg",
            label: "Books",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BooksPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: Colors.blue[800],
            icon: "assets/images/music.svg",
            label: "Musics",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicsPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: Colors.blue[900],
            icon: "assets/images/chef.svg",
            label: "Recipes",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipesPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: const Color.fromRGBO(11, 61, 140, 1),
            icon: "assets/images/plane.svg",
            label: "Travels",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TravelsPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
          HomeIcon(
            color: const Color.fromRGBO(9, 47, 110, 1),
            icon: "assets/images/coins.svg",
            label: "Expenses",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpensesPage(
                  userId: widget.userId,
                  db: widget._db,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
