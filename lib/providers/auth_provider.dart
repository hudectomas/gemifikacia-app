import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final SyncService _syncService;
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isAdmin => _authService.isAdmin;
  bool get isEmployee => _authService.isEmployee;
  bool get isChild => _authService.isChild;

  AuthProvider(this._authService, this._syncService);

  Future<void> initialize() async {
    await _authService.initialize();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, error) = await _authService.login(email, password);
      
      if (success) {
        // Sync data after login
        await _syncService.syncAll();
      }
      
      _error = error;
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (success, error) = await _authService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );
      
      if (success) {
        // Sync data after registration
        await _syncService.syncAll();
      }
      
      _error = error;
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}








