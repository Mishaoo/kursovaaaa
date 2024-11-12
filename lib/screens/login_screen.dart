// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'registration_screen.dart'; // Для переходу на екран реєстрації
import 'todo_list_screen.dart'; // Для переходу на екран завдань
import '../database_helper.dart'; // Для перевірки даних користувача

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = "";

  // Перевірка логіну та паролю
  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    bool userExists = await DatabaseHelper.checkUser(username, password);
    if (userExists) {
      // Якщо користувач знайдений, отримуємо його id
      var user = await DatabaseHelper.getUser(username);
      int userId = user!['id'];

      // Перехід на екран завдань, передаючи userId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListScreen(userId: userId)),
      );
    } else {
      setState(() {
        _errorMessage = "Невірний логін або пароль";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вхід')),
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
              onPressed: _login,
              child: Text('Увійти'),
            ),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            // Кнопка реєстрації
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()), // Переходимо на екран реєстрації
                );
              },
              child: Text("Ще немає акаунту? Зареєструйтесь!"),
            ),
          ],
        ),
      ),
    );
  }
}
