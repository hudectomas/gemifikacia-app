import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/user.dart' as user_model;
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../utils/helpers.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<user_model.User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    final users = await apiService.getUsers(
      role: _selectedRole == 'all' ? null : _selectedRole,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
    
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _changeUserRole(user_model.User user) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Zmeniť rolu: ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.child_care, color: AppTheme.primaryColor),
              title: const Text('Dieťa'),
              selected: user.role == 'child',
              onTap: () => Navigator.pop(context, 'child'),
            ),
            ListTile(
              leading: const Icon(Icons.work, color: AppTheme.infoColor),
              title: const Text('Zamestnanec'),
              selected: user.role == 'employee',
              onTap: () => Navigator.pop(context, 'employee'),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppTheme.errorColor),
              title: const Text('Admin'),
              selected: user.role == 'admin',
              onTap: () => Navigator.pop(context, 'admin'),
            ),
          ],
        ),
      ),
    );

    if (newRole != null && newRole != user.role) {
      final apiService = context.read<ApiService>();
      final success = await apiService.updateUserRole(user.id, newRole);

      if (mounted) {
        if (success) {
          _loadUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rola zmenená!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chyba pri zmene role'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Používatelia'),
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Hľadať používateľa...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadUsers();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Rola:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Všetci')),
                          ButtonSegment(value: 'child', label: Text('Deti')),
                          ButtonSegment(value: 'employee', label: Text('Zam.')),
                          ButtonSegment(value: 'admin', label: Text('Admin')),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _selectedRole = newSelection.first);
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getRoleColor(user.role),
                                child: Text(
                                  Helpers.getInitials(user.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(user.role),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getRoleDisplay(user.role),
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _changeUserRole(user),
                                  ),
                                ],
                              ),
                            ),
                          ).animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideX(begin: 0.2, end: 0);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👥', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          Text(
            'Žiadni používatelia',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.errorColor;
      case 'employee':
        return AppTheme.infoColor;
      case 'child':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getRoleDisplay(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'employee':
        return 'Zamestnanec';
      case 'child':
        return 'Dieťa';
      default:
        return role;
    }
  }
}

