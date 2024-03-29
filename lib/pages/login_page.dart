import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notebash_app/services/user_service.dart';
import 'package:sqflite/sqflite.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final Database _db;

  const LoginPage({super.key, required Database db}) : _db = db;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late UserService _service;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _clearForm();
    _service = UserService(db: widget._db);
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    final result = await _service.login(username, password);
    if (result.success) {
      _openHomePage(result.data!.id!);
    } else {
      setState(() {
        _errorMessage = result.message!;
      });
    }
  }

  void _clearForm() {
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _errorMessage = '';
    });
  }

  void _openHomePage(int userId) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(db: widget._db, userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    void register() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(db: widget._db),
        ),
      );
      _clearForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: SvgPicture.asset("assets/images/bash.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                  semanticsLabel: "Logo"),
            ),
            const SizedBox(width: 5.0),
            Text(
              'NoteBash',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Welcome to NoteBash!',
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              ),
              const SizedBox(height: 10.0),
              const Center(
                child: Text(
                  'A simple app for note taking and task management.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                "Username",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter your username',
                  suffixIcon: const Icon(Icons.person, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 12,
                  ),
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10.0),
              Text(
                "Password",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter your password',
                  suffixIcon: const Icon(Icons.lock, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 12,
                  ),
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () async => await _login(),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Login',
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 10.0),
                  OutlinedButton(
                      onPressed: () => register(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Register'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
