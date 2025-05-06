import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../Model/Note.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper _instance = NoteDatabaseHelper._internal();
  factory NoteDatabaseHelper() => _instance;
  NoteDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'notes.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      priority INTEGER NOT NULL,
      createdAt INTEGER NOT NULL,
      modifiedAt INTEGER NOT NULL,
      tags TEXT,
      color TEXT,
      isDone INTEGER DEFAULT 0,
      imagePath TEXT
    )
    ''');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm cột isDone nếu chưa có
      await db.execute("ALTER TABLE notes ADD COLUMN isDone INTEGER DEFAULT 0");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE notes ADD COLUMN imagePath TEXT");
    }
  }

  //hàm xóa database
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');
    await deleteDatabase(path);
  }

  // Thêm ghi chú
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'modifiedAt DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Note.fromMap(maps.first);
    return null;
  }

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xóa ghi chú
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await database;
    final maps = await db.query('notes', where: 'priority = ?', whereArgs: [priority]);
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa trong title hoặc content
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }
}