import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'database_interface.dart';

class AuthService {
  final ApiService _apiService;
  final IDatabaseService _databaseService;
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthService(this._apiService, this._databaseService);

  Future<void> initialize() async {
    // Load user from local database
    _currentUser = await _databaseService.getCurrentUser();
    
    if (_currentUser != null) {
      final token = await _databaseService.getAuthToken();
      if (token != null) {
        _apiService.setAuthToken(token);
        developer.log('User loaded from local storage: ${_currentUser!.name}');
      }
    }
  }

  Future<(bool, String?)> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      if (response.success && response.user != null && response.token != null) {
        _currentUser = User(
          id: response.user!.id,
          name: response.user!.name,
          email: response.user!.email,
          avatar: response.user!.avatar,
          role: response.user!.role,
        );
        
        await _databaseService.saveUser(_currentUser!, response.token!);
        developer.log('Login successful: ${_currentUser!.name} (${_currentUser!.role})');
        return (true, null);
      }
      
      return (false, response.message ?? 'Prihlásenie zlyhalo');
    } catch (e) {
      developer.log('Login error: $e');
      return (false, 'Chyba pripojenia: $e');
    }
  }

  Future<(bool, String?)> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await _apiService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );
      
      if (response.success && response.user != null && response.token != null) {
        _currentUser = User(
          id: response.user!.id,
          name: response.user!.name,
          email: response.user!.email,
          avatar: response.user!.avatar,
          role: response.user!.role,
        );
        
        await _databaseService.saveUser(_currentUser!, response.token!);
        developer.log('Registration successful: ${_currentUser!.name}');
        return (true, null);
      }
      
      return (false, response.message ?? 'Registrácia zlyhala');
    } catch (e) {
      developer.log('Registration error: $e');
      return (false, 'Chyba pripojenia: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      developer.log('Logout API error: $e');
    }
    
    await _databaseService.clearUser();
    _apiService.clearAuthToken();
    _currentUser = null;
    developer.log('User logged out');
  }

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEmployee => _currentUser?.isEmployee ?? false;
  bool get isChild => _currentUser?.isChild ?? false;
  bool get canGiveStamps => _currentUser?.canGiveStamps ?? false;
}

