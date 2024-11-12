// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Екран логіна

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Після запуску програми спочатку буде екран логіна
    );
  }
}
