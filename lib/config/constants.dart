class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://gemifikacia.dft.sk/api';
  
  // For different platforms:
  // Android Emulator: 'http://10.0.2.2:8000/api'
  // iOS Simulator: 'http://localhost:8000/api'
  // Physical Device: 'http://YOUR_IP:8000/api'
  
  // App Info
  static const String appName = 'Detský Pas';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'detsky_pas.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);
}






