import 'package:flutter/material.dart';
import 'login_screen.dart'; // Для повернення на екран логіна
import '../database_helper.dart'; // Для роботи з базою даних

class Todo {
  String title;
  bool isCompleted;
  int id;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class TodoListScreen extends StatefulWidget {
  final int userId; // Додамо userId, щоб знати, до якого користувача прив'язувати завдання

  TodoListScreen({required this.userId});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];

  // Отримання завдань користувача з бази даних
  void _loadTasks() async {
    final tasks = await DatabaseHelper.getTasks(widget.userId);
    setState(() {
      _todos = tasks.map((task) => Todo(
        id: task['id'],
        title: task['title'],
        isCompleted: task['isCompleted'] == 1,
      )).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Завантажуємо завдання при ініціалізації екрану
  }

  // Додавання нового завдання
  void _addTodo() {
    showDialog(
      context: context,
      builder: (context) {
        String newTodo = "";
        return AlertDialog(
          title: Text("Додати завдання"),
          content: TextField(
            onChanged: (value) {
              newTodo = value;
            },
            decoration: InputDecoration(hintText: "Введіть завдання"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newTodo.isNotEmpty) {
                  await DatabaseHelper.addTask(newTodo, widget.userId); // Додаємо завдання в базу
                  _loadTasks(); // Оновлюємо список завдань
                  Navigator.of(context).pop();
                }
              },
              child: Text("Додати"),
            ),
          ],
        );
      },
    );
  }

  // Оновлення статусу завдання
  void _toggleCompletion(int index) async {
    final task = _todos[index];
    int newStatus = task.isCompleted ? 0 : 1;
    await DatabaseHelper.updateTaskStatus(task.id, newStatus);
    _loadTasks(); // Оновлюємо статус завдання
  }

  // Видалення завдання
  void _deleteTodo(int index) async {
    final task = _todos[index];
    await DatabaseHelper.deleteTask(task.id);
    _loadTasks(); // Оновлюємо список завдань
  }

  // Вихід з акаунту
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Показати діалогове вікно для підтвердження видалення акаунту
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Видалити акаунт?"),
          content: Text("Це призведе до видалення всіх ваших завдань."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрити діалог
              },
              child: Text("Скасувати"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.deleteUser(widget.userId); // Видалити акаунт
                _logout(); // Вихід з акаунту після видалення
              },
              child: Text("Видалити", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Редагування завдання
  void _editTodo(int index) {
    String updatedTodo = _todos[index].title;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Редагувати завдання"),
          content: TextField(
            controller: TextEditingController(text: _todos[index].title),
            onChanged: (value) {
              updatedTodo = value;
            },
            decoration: InputDecoration(hintText: "Редагуйте завдання"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (updatedTodo.isNotEmpty) {
                  await DatabaseHelper.updateTask(_todos[index].id, updatedTodo); // Оновлюємо завдання
                  _loadTasks(); // Оновлюємо список завдань
                  Navigator.of(context).pop();
                }
              },
              child: Text("Зберегти"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Список завдань')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _todos[index].title,
                    style: TextStyle(
                      decoration: _todos[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editTodo(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTodo(index),
                      ),
                      IconButton(
                        icon: Icon(_todos[index].isCompleted
                            ? Icons.check_box
                            : Icons.check_box_outline_blank),
                        onPressed: () => _toggleCompletion(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _logout,
                  child: Text('Вийти з акаунту'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showDeleteConfirmationDialog,
                  child: Text('Видалити акаунт'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Червоний колір для кнопки
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
    );
  }
}
