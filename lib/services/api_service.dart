import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/task_model.dart';
import '../models/user_stamp.dart';
import '../models/season.dart';

class ApiService {
  String? _authToken;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  void setAuthToken(String token) {
    _authToken = token;
    developer.log('Auth token set: ${token.substring(0, 20)}...');
  }

  void clearAuthToken() {
    _authToken = null;
    developer.log('Auth token cleared');
  }

  // Authentication
  Future<LoginResponse> login(String email, String password) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/auth/login';
      developer.log('POST $url');
      developer.log('Body: {"email":"$email","password":"***"}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(AppConstants.apiTimeout);

      developer.log('Status: ${response.statusCode}');
      developer.log('Response: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);
        
        if (loginResponse.success && loginResponse.token != null) {
          setAuthToken(loginResponse.token!);
        }
        
        return loginResponse;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse(
          success: false,
          message: data['message'] as String? ?? 'Login failed',
        );
      }
    } catch (e) {
      developer.log('Login error: $e');
      return LoginResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<LoginResponse> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/auth/register';
      developer.log('POST $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(AppConstants.apiTimeout);

      developer.log('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);
        
        if (loginResponse.success && loginResponse.token != null) {
          setAuthToken(loginResponse.token!);
        }
        
        return loginResponse;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse(
          success: false,
          message: data['message'] as String? ?? 'Registration failed',
        );
      }
    } catch (e) {
      developer.log('Register error: $e');
      return LoginResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }

  Future<void> logout() async {
    try {
      final url = '${AppConstants.apiBaseUrl}/auth/logout';
      await http.post(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);
    } catch (e) {
      developer.log('Logout error: $e');
    } finally {
      clearAuthToken();
    }
  }

  // Tasks
  Future<List<TaskModel>> getTasks({bool activeOnly = true}) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/tasks${activeOnly ? '?active_only=true' : ''}';
      developer.log('GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      developer.log('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['tasks'] != null) {
          final tasksList = data['tasks'] as List;
          return tasksList.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      return [];
    } catch (e) {
      developer.log('Get tasks error: $e');
      return [];
    }
  }

  // Stamps
  Future<List<UserStamp>> getStamps({int? userId}) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/stamps${userId != null ? '?user_id=$userId' : ''}';
      developer.log('GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['stamps'] != null) {
          final stampsList = data['stamps'] as List;
          return stampsList.map((json) => UserStamp.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      return [];
    } catch (e) {
      developer.log('Get stamps error: $e');
      return [];
    }
  }

  Future<bool> giveStamp(int userId, int taskId, {String? notes}) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/stamps/give';
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'task_id': taskId,
          if (notes != null) 'notes': notes,
        }),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Give stamp error: $e');
      return false;
    }
  }

  // QR Code validation
  Future<Map<String, dynamic>> validateQrCodeAsync(String qrCode, int userId) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/stamps/validate-qr';
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'qr_code': qrCode,
          'user_id': userId,
        }),
      ).timeout(AppConstants.apiTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': data['success'] as bool? ?? false,
        'message': data['message'] as String?,
      };
    } catch (e) {
      developer.log('QR validation error: $e');
      return {
        'success': false,
        'message': 'Chyba pripojenia: $e',
      };
    }
  }

  // Get all users (admin only)
  Future<List<User>> getUsers({String? role, String? search}) async {
    try {
      var url = '${AppConstants.apiBaseUrl}/users?';
      if (role != null) url += 'role=$role&';
      if (search != null) url += 'search=$search';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['users'] != null) {
          final usersList = data['users'] as List;
          return usersList.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      return [];
    } catch (e) {
      developer.log('Get users error: $e');
      return [];
    }
  }

  // Update user role (admin only)
  Future<bool> updateUserRole(int userId, String role) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/users/$userId/role';
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({'role': role}),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Update role error: $e');
      return false;
    }
  }

  // Create task (admin only)
  Future<bool> createTask(TaskModel task) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/tasks';
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(task.toJson()),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Create task error: $e');
      return false;
    }
  }

  // Update task (admin only)
  Future<bool> updateTask(int taskId, TaskModel task) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/tasks/$taskId';
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(task.toJson()),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Update task error: $e');
      return false;
    }
  }

  // Delete task (admin only)
  Future<bool> deleteTask(int taskId) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/tasks/$taskId';
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Delete task error: $e');
      return false;
    }
  }

  // Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10, int? seasonId}) async {
    try {
      var url = '${AppConstants.apiBaseUrl}/users/leaderboard?limit=$limit';
      if (seasonId != null) {
        url += '&season_id=$seasonId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['leaderboard'] != null) {
          return (data['leaderboard'] as List).cast<Map<String, dynamic>>();
        }
      }
      
      return [];
    } catch (e) {
      developer.log('Get leaderboard error: $e');
      return [];
    }
  }

  // Get season statistics
  Future<Map<String, dynamic>> getSeasonStatistics(int seasonId) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/seasons/$seasonId/statistics';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      developer.log('Season statistics response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['statistics'] != null) {
          return data['statistics'] as Map<String, dynamic>;
        }
      }
      
      return {
        'total_users': 0,
        'total_stamps': 0,
        'total_points': 0,
        'completed_tasks': 0,
      };
    } catch (e) {
      developer.log('Get season statistics error: $e');
      return {
        'total_users': 0,
        'total_stamps': 0,
        'total_points': 0,
        'completed_tasks': 0,
      };
    }
  }

  // Seasons
  Future<List<Season>> getSeasons() async {
    try {
      final url = '${AppConstants.apiBaseUrl}/seasons';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['seasons'] != null) {
          final seasonsList = data['seasons'] as List;
          return seasonsList.map((json) => Season.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      
      return [];
    } catch (e) {
      developer.log('Get seasons error: $e');
      return [];
    }
  }

  Future<Season?> getActiveSeason() async {
    try {
      final url = '${AppConstants.apiBaseUrl}/seasons/active';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['season'] != null) {
          return Season.fromJson(data['season'] as Map<String, dynamic>);
        }
      }
      
      return null;
    } catch (e) {
      developer.log('Get active season error: $e');
      return null;
    }
  }

  Future<bool> createSeason(Season season) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/seasons';
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(season.toJson()),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Create season error: $e');
      return false;
    }
  }

  Future<bool> activateSeason(int seasonId) async {
    try {
      final url = '${AppConstants.apiBaseUrl}/seasons/$seasonId/activate';
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      developer.log('Activate season error: $e');
      return false;
    }
  }
}

