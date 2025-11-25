import 'package:flutter/foundation.dart';
import '../models/user_stamp.dart';
import '../services/database_interface.dart';
import '../services/auth_service.dart';

class StampProvider with ChangeNotifier {
  final IDatabaseService _databaseService;
  final AuthService _authService;
  
  List<UserStamp> _stamps = [];
  int _totalPoints = 0;
  bool _isLoading = false;
  
  List<UserStamp> get stamps => _stamps;
  int get totalPoints => _totalPoints;
  int get totalStamps => _stamps.length;
  bool get isLoading => _isLoading;

  StampProvider(this._databaseService, this._authService);

  Future<void> loadStamps() async {
    if (_authService.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _stamps = await _databaseService.getStamps(_authService.currentUser!.id);
      _totalPoints = await _databaseService.getTotalPoints(_authService.currentUser!.id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStamp(UserStamp stamp) async {
    await _databaseService.saveStamp(stamp);
    await loadStamps();
  }
}

