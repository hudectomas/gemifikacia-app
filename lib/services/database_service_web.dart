// Web-compatible database service (uses SharedPreferences instead of SQLite)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/task_model.dart';
import '../models/user_stamp.dart';
import 'database_interface.dart';

class DatabaseService implements IDatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  @override
  Future<void> initialize() async {
    // No initialization needed for web
  }

  // User operations
  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('current_user');
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    }
    
    return null;
  }

  @override
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Future<void> saveUser(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
    await prefs.setString('auth_token', token);
    await prefs.setString('last_sync', DateTime.now().toIso8601String());
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('auth_token');
  }

  // Task operations
  @override
  Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    
    if (tasksJson != null) {
      final tasksList = jsonDecode(tasksJson) as List;
      return tasksList.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    return [];
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // Stamp operations
  @override
  Future<List<UserStamp>> getStamps(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final stampsJson = prefs.getString('stamps_$userId');
    
    if (stampsJson != null) {
      final stampsList = jsonDecode(stampsJson) as List;
      return stampsList.map((json) => UserStamp.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    return [];
  }

  @override
  Future<List<int>> getCompletedTaskIds(int userId) async {
    final stamps = await getStamps(userId);
    return stamps.map((s) => s.taskId).toList();
  }

  @override
  Future<void> saveStamp(UserStamp stamp) async {
    final prefs = await SharedPreferences.getInstance();
    final stamps = await getStamps(stamp.userId);
    
    // Add new stamp if not exists
    if (!stamps.any((s) => s.taskId == stamp.taskId && s.userId == stamp.userId)) {
      stamps.add(stamp);
      await prefs.setString('stamps_${stamp.userId}', 
        jsonEncode(stamps.map((s) => s.toJson()).toList()));
    }
  }

  @override
  Future<int> getTotalPoints(int userId) async {
    final stamps = await getStamps(userId);
    return stamps.fold<int>(0, (sum, stamp) => sum + (stamp.task?.points ?? 0));
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> close() async {
    // Nothing to close for web
  }
}

