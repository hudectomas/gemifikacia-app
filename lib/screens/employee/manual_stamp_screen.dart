import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/user.dart' as user_model;
import '../../models/task_model.dart';
import '../../services/api_service.dart';
import '../../services/sync_service.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../utils/helpers.dart';

class ManualStampScreen extends StatefulWidget {
  const ManualStampScreen({super.key});

  @override
  State<ManualStampScreen> createState() => _ManualStampScreenState();
}

class _ManualStampScreenState extends State<ManualStampScreen> {
  final _searchController = TextEditingController();
  List<user_model.User> _users = [];
  List<TaskModel> _tasks = [];
  List<TaskModel> _availableTasks = []; // Úlohy, ktoré dieťa ešte nemá
  List<int> _userCompletedTaskIds = []; // ID úloh, ktoré už dieťa má
  user_model.User? _selectedUser;
  TaskModel? _selectedTask;
  bool _isLoading = false;
  bool _isLoadingTasks = false;
  bool _isOffline = false;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final syncService = context.read<SyncService>();
    final databaseService = context.read<DatabaseService>();
    final apiService = context.read<ApiService>();
    
    final isOnline = await syncService.isOnline();
    
    if (isOnline) {
      // Online: načítaj z API a ulož do lokálnej DB
      try {
        final tasks = await apiService.getTasks();
        final users = await apiService.getUsers(role: 'child');
        
        // Ulož do lokálnej databázy pre offline použitie
        await databaseService.saveTasks(tasks);
        await databaseService.saveParticipants(users);
        
        setState(() {
          _tasks = tasks;
          _users = users;
          _isOffline = false;
          _isLoading = false;
        });
      } catch (e) {
        // Ak API zlyhá, použi lokálne dáta
        await _loadFromLocalDatabase(databaseService);
      }
    } else {
      // Offline: načítaj z lokálnej databázy
      await _loadFromLocalDatabase(databaseService);
    }
  }

  Future<void> _loadFromLocalDatabase(DatabaseService databaseService) async {
    final tasks = await databaseService.getTasks();
    final users = await databaseService.getParticipants();
    
    setState(() {
      _tasks = tasks;
      _users = users;
      _isOffline = true;
      _isLoading = false;
    });
  }

  List<user_model.User> get _filteredUsers {
    if (_searchController.text.isEmpty) {
      return _users;
    }
    
    final query = _searchController.text.toLowerCase();
    return _users.where((user) =>
      user.name.toLowerCase().contains(query) ||
      user.email.toLowerCase().contains(query)
    ).toList();
  }

  Future<void> _loadUserCompletedTasks(int userId) async {
    setState(() => _isLoadingTasks = true);
    
    final apiService = context.read<ApiService>();
    final databaseService = context.read<DatabaseService>();
    final syncService = context.read<SyncService>();
    
    try {
      List<int> completedTaskIds = [];
      
      final isOnline = await syncService.isOnline();
      
      if (isOnline && !_isOffline) {
        // Online: načítaj pečiatky z API
        final stamps = await apiService.getStamps(userId: userId);
        completedTaskIds = stamps.map((stamp) => stamp.taskId).toSet().toList();
      } else {
        // Offline: načítaj pečiatky z lokálnej databázy
        completedTaskIds = await databaseService.getCompletedTaskIds(userId);
      }
      
      // Filtruj úlohy - zobraz len tie, ktoré ešte nemá
      final available = _tasks.where((task) => !completedTaskIds.contains(task.id)).toList();
      
      setState(() {
        _userCompletedTaskIds = completedTaskIds;
        _availableTasks = available;
        _isLoadingTasks = false;
        _selectedTask = null; // Reset vybranej úlohy
      });
    } catch (e) {
      setState(() => _isLoadingTasks = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri načítaní úloh: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _giveStamp() async {
    if (_selectedUser == null || _selectedTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vyber dieťa a úlohu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final syncService = context.read<SyncService>();
    final apiService = context.read<ApiService>();
    final authProvider = context.read<AuthProvider>();
    
    final isOnline = await syncService.isOnline();
    bool success = false;
    bool savedOffline = false;

    if (isOnline) {
      // Online: pošli na server
      success = await apiService.giveStamp(
        _selectedUser!.id,
        _selectedTask!.id,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      if (success) {
        await syncService.syncAll();
      }
    } else {
      // Offline: ulož lokálne a synchronizuj neskôr
      await syncService.saveOfflineStamp(
        userId: _selectedUser!.id,
        taskId: _selectedTask!.id,
        stampedBy: authProvider.currentUser?.id ?? 0,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      success = true;
      savedOffline = true;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(savedOffline ? '📱' : '✅', style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(savedOffline ? 'Uložené offline!' : 'Úspech!', 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(savedOffline 
                  ? 'Pečiatka pre ${_selectedUser!.name} bola uložená a synchronizuje sa po pripojení na internet.'
                  : 'Pečiatka bola pridaná pre ${_selectedUser!.name}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: savedOffline ? AppTheme.warningColor : AppTheme.successColor,
                ),
                child: const Text('Hotovo'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chyba pri pridávaní pečiatky'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Pridať Pečiatku'),
            if (_isOffline) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Offline', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: _isOffline ? AppTheme.infoColor : AppTheme.warningColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Search child
            Text('1️⃣ Vyhľadaj dieťa', style: AppTheme.headingMedium).animate().fadeIn(),
            const SizedBox(height: 12),
            
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Vyhľadaj dieťa (alebo zobraz všetky)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: 12),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_filteredUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.infoColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Žiadne deti nenájdené'),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Prihlásené deti (${_filteredUsers.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final isSelected = _selectedUser?.id == user.id;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.primaryColor.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                                  : null,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor.withOpacity(0.3),
                                child: Text(
                                  Helpers.getInitials(user.name),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(user.email),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                                  : null,
                              onTap: () {
                                setState(() => _selectedUser = user);
                                _loadUserCompletedTasks(user.id);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Step 2: Select task
            Row(
              children: [
                Text('2️⃣ Vyber úlohu', style: AppTheme.headingMedium),
                if (_selectedUser != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.infoColor, width: 2),
                    ),
                    child: Text(
                      '${_availableTasks.length} dostupných',
                      style: const TextStyle(
                        color: AppTheme.infoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            
            if (_selectedUser == null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.infoColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Najprv vyber dieťa'),
                    ),
                  ],
                ),
              )
            else if (_isLoadingTasks)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availableTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: AppTheme.successColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎉 Výborne!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedUser!.name} má už všetky pečiatky!',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableTasks.length,
                  itemBuilder: (context, index) {
                    final task = _availableTasks[index];
                    final isSelected = _selectedTask?.id == task.id;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getCategoryColor(task.category),
                                _getCategoryColor(task.category).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(task.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text('${task.points} bodov • ${task.categoryDisplay}'),
                        selected: isSelected,
                        onTap: () => setState(() => _selectedTask = task),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '⭐ ${task.points}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Step 3: Optional notes
            Text('3️⃣ Poznámka (voliteľné)', style: AppTheme.headingMedium).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Napríklad: Výborne zvládnuté!',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 30),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedUser != null && _selectedTask != null && !_isLoading)
                    ? _giveStamp
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle),
                          const SizedBox(width: 10),
                          Text(
                            _selectedUser != null && _selectedTask != null
                                ? 'Pridať pečiatku pre ${_selectedUser!.name}'
                                : 'Vyber dieťa a úlohu',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  // Funkcia na získanie farby kategórie
  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ski_school':
        return AppTheme.skiSchoolColor;
      case 'buffet':
        return AppTheme.buffetColor;
      case 'activity':
        return AppTheme.activityColor;
      case 'safety':
        return AppTheme.safetyColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}

