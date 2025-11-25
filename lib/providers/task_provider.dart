import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/database_interface.dart';
import '../services/auth_service.dart';

class TaskProvider with ChangeNotifier {
  final IDatabaseService _databaseService;
  final AuthService _authService;
  
  List<TaskModel> _tasks = [];
  List<int> _completedTaskIds = [];
  bool _isLoading = false;
  
  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get completedTasks => 
      _tasks.where((task) => _completedTaskIds.contains(task.id)).toList();
  List<TaskModel> get pendingTasks => 
      _tasks.where((task) => !_completedTaskIds.contains(task.id)).toList();
  int get totalTasks => _tasks.length;
  int get completedCount => _completedTaskIds.length;
  double get completionRate => 
      totalTasks > 0 ? (completedCount / totalTasks) * 100 : 0;
  bool get isLoading => _isLoading;

  TaskProvider(this._databaseService, this._authService);

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _databaseService.getTasks();
      
      if (_authService.currentUser != null) {
        _completedTaskIds = await _databaseService.getCompletedTaskIds(
          _authService.currentUser!.id,
        );
        
        // Mark completed tasks
        for (var task in _tasks) {
          task.isCompleted = _completedTaskIds.contains(task.id);
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TaskModel> getTasksByCategory(String? category) {
    if (category == null || category == 'all') {
      return _tasks;
    }
    return _tasks.where((task) => task.category == category).toList();
  }
}

