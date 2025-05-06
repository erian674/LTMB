import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/user.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT,
        email TEXT,
        password TEXT,
        avatar TEXT,
        createdAt TEXT,
        lastActive TEXT,
        isAdmin INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        priority INTEGER,
        dueDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        assignedTo TEXT,
        createdBy TEXT,
        category TEXT,
        attachments TEXT
      )
    ''');
  }

  //User

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Đăng ký tài khoản mới
  Future<bool> registerUser({
    required String id,
    required String username,
    required String email,
    required String password,
    String? avatar,
  }) async {
    final db = await database;

    // Kiểm tra trùng email hoặc username
    final check = await db.query('users',
      where: 'email = ? OR username = ?',
      whereArgs: [email, username],
    );
    if (check.isNotEmpty) return false;
    // ✅ Kiểm tra xem có phải người dùng đầu tiên không
    final countQuery = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final userCount = Sqflite.firstIntValue(countQuery) ?? 0;
    final isAdmin = userCount == 0; // Người đầu tiên sẽ là admin

    final user = User(
      id: id,
      username: username,
      password: password,
      email: email,
      avatar: avatar,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      isAdmin: isAdmin,
    );

    await db.insert('users', user.toMap());

    return true;
  }

  // Đăng nhập người dùng
  Future<User?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isNotEmpty) {
      final user = User.fromMap(result.first);
      // cập nhật lastActive
      await db.update('users', {
        'lastActive': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [user.id]);

      return user;
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<String?> getUsernameById(String userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['username'] as String;
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first); // Chuyển đổi Map thành đối tượng User
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<void> updateLastActive(String userId) async {
    final db = await database;
    await db.update(
      'users',
      {'lastActive': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Đổi mật khẩu người dùng
  Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await database;

    // Xác minh mật khẩu cũ
    final user = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, oldPassword],
    );

    if (user.isEmpty) return false; // Sai mật khẩu cũ

    // Cập nhật mật khẩu mới
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return true;
  }

  //Task

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks({String? userId, bool isAdmin = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (isAdmin || userId == null) {
      maps = await db.query('tasks');
    } else {
      maps = await db.query(
        'tasks',
        where: 'assignedTo = ? OR createdBy = ?',
        whereArgs: [userId, userId],
      );
    }

    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('tasks', where: 'assignedTo = ?', whereArgs: [userId]);

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }
  Future<List<Task>> getTasksForUser(String userId, String role) async {
    final db = await database;

    if (role == 'admin') {
      // Admin xem tất cả
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      return maps.map((map) => Task.fromMap(map)).toList();
    } else {
      // User thường: chỉ xem task do họ tạo hoặc được giao
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'createdBy = ? OR assignedTo = ?',
        whereArgs: [userId, userId],
      );
      return maps.map((map) => Task.fromMap(map)).toList();
    }
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Task.fromMap(result.first);
    return null;
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Filtering & Search

  Future<List<Task>> searchTasks(String keyword, {String? userId, bool isAdmin = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> result;

    if (isAdmin) {
      result = await db.query(
        'tasks',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
      );
    } else {
      result = await db.query(
        'tasks',
        where: '(title LIKE ? OR description LIKE ?) AND assignedTo = ?',
        whereArgs: ['%$keyword%', '%$keyword%', userId],
      );
    }

    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> filterTasksByStatus(String status, {String? userId, bool isAdmin = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> result;

    if (isAdmin) {
      result = await db.query(
        'tasks',
        where: 'status = ?',
        whereArgs: [status],
      );
    } else {
      result = await db.query(
        'tasks',
        where: 'status = ? AND assignedTo = ?',
        whereArgs: [status, userId],
      );
    }

    return result.map((e) => Task.fromMap(e)).toList();
  }
}
