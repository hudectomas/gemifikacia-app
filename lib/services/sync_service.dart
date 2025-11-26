import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'database_interface.dart';
import 'auth_service.dart';
import '../models/user_stamp.dart';

class SyncService {
  final ApiService _apiService;
  final IDatabaseService _databaseService;
  final AuthService _authService;
  
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingStampsCount = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingStampsCount => _pendingStampsCount;

  SyncService(this._apiService, this._databaseService, this._authService);

  /// Start listening for connectivity changes and auto-sync
  void startAutoSync() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final isConnected = results.any((r) => 
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet
      );
      
      if (isConnected && _authService.isAuthenticated) {
        developer.log('Internet connected - starting auto-sync...');
        await syncAll();
      }
    });
  }

  /// Stop listening for connectivity changes
  void stopAutoSync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any((r) =>
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.ethernet
    );
  }

  /// Update pending stamps count
  Future<void> updatePendingCount() async {
    final pending = await _databaseService.getPendingStamps();
    _pendingStampsCount = pending.length;
  }

  /// Full sync - downloads all data and uploads pending stamps
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
      // 1. First upload pending stamps to server
      await _uploadPendingStamps();

      // 2. Sync tasks
      final tasks = await _apiService.getTasks(activeOnly: true);
      await _databaseService.saveTasks(tasks);
      developer.log('Tasks synced: ${tasks.length}');

      // 3. Sync stamps for current user
      if (_authService.currentUser != null) {
        final stamps = await _apiService.getStamps(
          userId: _authService.currentUser!.id,
        );
        
        for (var stamp in stamps) {
          // Mark as synced since it came from server
          final syncedStamp = UserStamp(
            id: stamp.id,
            userId: stamp.userId,
            taskId: stamp.taskId,
            stampedBy: stamp.stampedBy,
            stampedAt: stamp.stampedAt,
            qrCodeUsed: stamp.qrCodeUsed,
            synced: true,
            notes: stamp.notes,
            task: stamp.task,
          );
          await _databaseService.saveStamp(syncedStamp);
        }
        developer.log('Stamps synced: ${stamps.length}');
      }

      // 4. For admin/employee - sync participants (children)
      if (_authService.currentUser != null && 
          (_authService.currentUser!.isAdmin || _authService.currentUser!.isEmployee)) {
        await _syncParticipants();
      }

      _lastSyncTime = DateTime.now();
      await updatePendingCount();
      developer.log('Sync completed successfully');
      return (true, null);
    } catch (e) {
      developer.log('Sync error: $e');
      return (false, 'Chyba synchronizácie: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload pending (offline) stamps to server
  Future<void> _uploadPendingStamps() async {
    final pendingStamps = await _databaseService.getPendingStamps();
    developer.log('Uploading ${pendingStamps.length} pending stamps...');
    
    for (var stamp in pendingStamps) {
      try {
        final success = await _apiService.giveStamp(
          stamp.userId,
          stamp.taskId,
          notes: stamp.notes,
        );
        
        if (success) {
          await _databaseService.markStampAsSyncedByUserAndTask(stamp.userId, stamp.taskId);
          developer.log('Stamp synced: user=${stamp.userId}, task=${stamp.taskId}');
        } else {
          developer.log('Failed to sync stamp: user=${stamp.userId}, task=${stamp.taskId}');
        }
      } catch (e) {
        developer.log('Error syncing stamp: $e');
      }
    }
  }

  /// Sync participants (children) for admin/employee offline mode
  Future<void> _syncParticipants() async {
    try {
      final children = await _apiService.getUsers(role: 'child');
      await _databaseService.saveParticipants(children);
      developer.log('Participants synced: ${children.length}');
    } catch (e) {
      developer.log('Error syncing participants: $e');
    }
  }

  /// Save stamp locally (offline mode) - will be synced when online
  Future<void> saveOfflineStamp({
    required int userId,
    required int taskId,
    required int stampedBy,
    String? notes,
  }) async {
    // Get task details for local storage
    final tasks = await _databaseService.getTasks();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;
    
    final stamp = UserStamp(
      id: 0, // Will be assigned by server
      userId: userId,
      taskId: taskId,
      stampedBy: stampedBy,
      stampedAt: DateTime.now(),
      synced: false, // Mark as not synced
      notes: notes,
      task: task,
    );
    
    await _databaseService.saveStamp(stamp);
    await updatePendingCount();
    developer.log('Offline stamp saved: user=$userId, task=$taskId');
    
    // Try to sync immediately if online
    if (await isOnline()) {
      await _uploadPendingStamps();
      await updatePendingCount();
    }
  }

  /// Get participants from local database (for offline search)
  Future<List<dynamic>> getOfflineParticipants({String? search}) async {
    if (search != null && search.isNotEmpty) {
      return await _databaseService.searchParticipants(search);
    }
    return await _databaseService.getParticipants();
  }
}

