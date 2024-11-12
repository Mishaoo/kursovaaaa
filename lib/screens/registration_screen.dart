// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import './/database_helper.dart'; // Для додавання користувача до бази даних
import 'login_screen.dart'; // Для переходу на екран логіна

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = "";

  // Реєстрація нового користувача
  void _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Перевірка, чи користувач уже існує
    bool userExists = await DatabaseHelper.checkUser(username, password);
    if (userExists) {
      setState(() {
        _errorMessage = "Цей користувач уже існує";
      });
    } else {
      // Додавання нового користувача до бази даних
      await DatabaseHelper.addUser(username, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Переходимо на екран логіна
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Реєстрація')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Логін'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Зареєструватися'),
            ),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
