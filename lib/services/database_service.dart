import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/task_model.dart';
import '../models/user_stamp.dart';
import 'database_interface.dart';
import 'dart:convert';

class DatabaseService implements IDatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  @override
  Future<void> initialize() async {
    // Initialize database
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('detsky_pas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar TEXT,
        role TEXT NOT NULL,
        token TEXT,
        last_sync TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT,
        points INTEGER NOT NULL,
        category TEXT,
        is_active INTEGER NOT NULL,
        task_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stamps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        task_id INTEGER NOT NULL,
        stamped_by INTEGER NOT NULL,
        stamped_at TEXT NOT NULL,
        qr_code_used TEXT,
        synced INTEGER NOT NULL,
        notes TEXT,
        task_json TEXT,
        UNIQUE(user_id, task_id)
      )
    ''');
  }

  // User operations
  @override
  Future<User?> getCurrentUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    
    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'] as int,
        name: maps.first['name'] as String,
        email: maps.first['email'] as String,
        avatar: maps.first['avatar'] as String?,
        role: maps.first['role'] as String,
        lastSync: maps.first['last_sync'] != null
            ? DateTime.parse(maps.first['last_sync'] as String)
            : null,
      );
    }
    
    return null;
  }

  @override
  Future<String?> getAuthToken() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    
    if (maps.isNotEmpty) {
      return maps.first['token'] as String?;
    }
    
    return null;
  }

  @override
  Future<void> saveUser(User user, String token) async {
    final db = await database;
    await db.delete('users');
    await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'avatar': user.avatar,
      'role': user.role,
      'token': token,
      'last_sync': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> clearUser() async {
    final db = await database;
    await db.delete('users');
  }

  // Task operations
  @override
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks', where: 'is_active = 1', orderBy: 'task_order');
    
    return maps.map((map) => TaskModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String?,
      points: map['points'] as int,
      category: map['category'] as String?,
      isActive: (map['is_active'] as int) == 1,
      order: map['task_order'] as int,
    )).toList();
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final db = await database;
    await db.delete('tasks');
    
    for (var task in tasks) {
      await db.insert('tasks', {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'icon': task.icon,
        'points': task.points,
        'category': task.category,
        'is_active': task.isActive ? 1 : 0,
        'task_order': task.order,
      });
    }
  }

  // Stamp operations
  @override
  Future<List<UserStamp>> getStamps(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user_stamps',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'stamped_at DESC',
    );
    
    return maps.map((map) {
      TaskModel? task;
      if (map['task_json'] != null) {
        task = TaskModel.fromJson(jsonDecode(map['task_json'] as String) as Map<String, dynamic>);
      }
      
      return UserStamp(
        id: map['id'] as int,
        userId: map['user_id'] as int,
        taskId: map['task_id'] as int,
        stampedBy: map['stamped_by'] as int,
        stampedAt: DateTime.parse(map['stamped_at'] as String),
        qrCodeUsed: map['qr_code_used'] as String?,
        synced: (map['synced'] as int) == 1,
        notes: map['notes'] as String?,
        task: task,
      );
    }).toList();
  }

  @override
  Future<List<int>> getCompletedTaskIds(int userId) async {
    final db = await database;
    final maps = await db.query(
      'user_stamps',
      columns: ['task_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    return maps.map((map) => map['task_id'] as int).toList();
  }

  @override
  Future<void> saveStamp(UserStamp stamp) async {
    final db = await database;
    await db.insert(
      'user_stamps',
      {
        'user_id': stamp.userId,
        'task_id': stamp.taskId,
        'stamped_by': stamp.stampedBy,
        'stamped_at': stamp.stampedAt.toIso8601String(),
        'qr_code_used': stamp.qrCodeUsed,
        'synced': stamp.synced ? 1 : 0,
        'notes': stamp.notes,
        'task_json': stamp.task != null ? jsonEncode(stamp.task!.toJson()) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> getTotalPoints(int userId) async {
    final stamps = await getStamps(userId);
    return stamps.fold<int>(0, (sum, stamp) => sum + (stamp.task?.points ?? 0));
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('users');
    await db.delete('tasks');
    await db.delete('user_stamps');
  }

  @override
  Future<void> close() async {
    final db = await _database;
    db?.close();
  }
}

