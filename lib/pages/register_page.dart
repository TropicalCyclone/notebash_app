import 'package:flutter/material.dart';
import 'package:notebash_app/models/user.dart';
import 'package:notebash_app/services/user_service.dart';
import 'package:sqflite/sqflite.dart';

class RegisterPage extends StatefulWidget {
  final Database _db;

  const RegisterPage({super.key, required Database db}) : _db = db;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String _errorMessage = '';
  late UserService _service;

  @override
  void initState() {
    super.initState();
    _service = UserService(db: widget._db);
    _clearForm();
  }

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
      });
      return;
    }

    if (_confirmController.text != _passwordController.text) {
      setState(() {
        _errorMessage = 'Password not match';
      });
      return;
    }

    User user = User(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    final result = await _service.register(user);

    if (result.success) {
      await _alertDialog();
      _clearForm();
      _back();
    } else {
      setState(() {
        _errorMessage = result.message!;
      });
    }
  }

  Future _alertDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Register'),
          content: const Text('You have successfully registered.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _usernameController.clear();
    _passwordController.clear();
    _confirmController.clear();
    _errorMessage = '';

    setState(() {});
  }

  void _back() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 10.0),
              Text(
                "Confirm Password",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Confirm password',
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
                  onPressed: () async => await _register(),
                  child: const Text(
                    'Register',
                    textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}
