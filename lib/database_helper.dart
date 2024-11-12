// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Підключення до бази даних
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Ініціалізація бази даних
  static Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo_app.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            username TEXT,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            title TEXT,
            isCompleted INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
      },
      version: 1,
    );
  }

  // Додавання завдання
  static Future<void> addTask(String title, int userId) async {
    final db = await database;
    await db.insert(
      'tasks',
      {
        'userId': userId,
        'title': title,
        'isCompleted': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Оновлення завдання
  static Future<void> updateTask(int id, String title) async {
    final db = await database;
    await db.update(
      'tasks',
      {'title': title},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Оновлення статусу завдання (завершено/незавершено)
  static Future<void> updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isCompleted': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Видалення завдання
  static Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Видалення користувача та всіх його завдань
  static Future<void> deleteUser(int userId) async {
    final db = await database;

    // Спочатку видаляємо завдання користувача
    await db.delete(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    // Потім видаляємо самого користувача
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Отримання завдань користувача
  static Future<List<Map<String, dynamic>>> getTasks(int userId) async {
    final db = await database;
    return db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Перевірка наявності користувача за ім'ям та паролем
  static Future<bool> checkUser(String username, String password) async {
    final db = await database;
    var res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty; // Якщо користувач знайдений
  }

  // Додавання нового користувача
  static Future<void> addUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Отримання користувача за ім'ям
  static Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    var res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return res.isNotEmpty ? res.first : null;
  }
}
