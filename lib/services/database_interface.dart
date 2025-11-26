import '../models/user.dart';
import '../models/task_model.dart';
import '../models/user_stamp.dart';

abstract class IDatabaseService {
  Future<void> initialize();
  
  // User operations
  Future<User?> getCurrentUser();
  Future<String?> getAuthToken();
  Future<void> saveUser(User user, String token);
  Future<void> clearUser();
  
  // Task operations
  Future<List<TaskModel>> getTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
  
  // Stamp operations
  Future<List<UserStamp>> getStamps(int userId);
  Future<List<int>> getCompletedTaskIds(int userId);
  Future<void> saveStamp(UserStamp stamp);
  Future<int> getTotalPoints(int userId);
  
  // Participants (children) for offline mode - admin/employee
  Future<List<User>> getParticipants();
  Future<void> saveParticipants(List<User> participants);
  Future<User?> getParticipantById(int userId);
  Future<List<User>> searchParticipants(String query);
  
  // Pending stamps (offline stamps to sync)
  Future<List<UserStamp>> getPendingStamps();
  Future<void> markStampAsSynced(int odtampId);
  Future<void> markStampAsSyncedByUserAndTask(int userId, int taskId);
  
  // Clear all
  Future<void> clearAll();
  Future<void> close();
}







