import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'database_interface.dart';
import 'auth_service.dart';

class SyncService {
  final ApiService _apiService;
  final IDatabaseService _databaseService;
  final AuthService _authService;
  
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncService(this._apiService, this._databaseService, this._authService);

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
           connectivityResult == ConnectivityResult.wifi ||
           connectivityResult == ConnectivityResult.ethernet;
  }

  Future<(bool, String?)> syncAll() async {
    if (_isSyncing) {
      return (false, 'Synchronizácia už prebieha');
    }

    if (!_authService.isAuthenticated) {
      return (false, 'Nie ste prihlásený');
    }

    if (!await isOnline()) {
      return (false, 'Žiadne internetové pripojenie');
    }

    _isSyncing = true;
    developer.log('Starting sync...');

    try {
      // Sync tasks
      final tasks = await _apiService.getTasks(activeOnly: true);
      await _databaseService.saveTasks(tasks);
      developer.log('Tasks synced: ${tasks.length}');

      // Sync stamps
      if (_authService.currentUser != null) {
        final stamps = await _apiService.getStamps(
          userId: _authService.currentUser!.id,
        );
        
        for (var stamp in stamps) {
          await _databaseService.saveStamp(stamp);
        }
        developer.log('Stamps synced: ${stamps.length}');
      }

      _lastSyncTime = DateTime.now();
      developer.log('Sync completed successfully');
      return (true, null);
    } catch (e) {
      developer.log('Sync error: $e');
      return (false, 'Chyba synchronizácie: $e');
    } finally {
      _isSyncing = false;
    }
  }
}

