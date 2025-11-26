import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/stamp_provider.dart';
import '../../services/sync_service.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Odhlásenie'),
        content: const Text('Naozaj sa chceš odhlásiť?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Odhlásiť'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _handleSync(BuildContext context) async {
    final syncService = context.read<SyncService>();
    final (success, error) = await syncService.syncAll();
    
    if (context.mounted) {
      if (success) {
        await context.read<TaskProvider>().loadTasks();
        await context.read<StampProvider>().loadStamps();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Dáta synchronizované! ✨' : error ?? 'Chyba'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Nastavenia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? '', style: AppTheme.headingMedium),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: AppTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _getRoleGradient(user?.role),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplay(user?.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 100.ms),
            
            const SizedBox(height: 30),
            
            // Sync Section
            _buildSettingCard(
              icon: Icons.sync,
              title: 'Synchronizácia',
              subtitle: 'Synchronizovať dáta so serverom',
              color: AppTheme.infoColor,
              onTap: () => _handleSync(context),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            // About
            _buildSettingCard(
              icon: Icons.info_outline,
              title: 'O aplikácii',
              subtitle: 'Verzia 1.0.0',
              color: AppTheme.textSecondary,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Detský Pas',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Text('⛷️', style: TextStyle(fontSize: 40)),
                );
              },
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 40),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppTheme.errorColor.withOpacity(0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Odhlásiť sa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ).animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplay(String? role) {
    switch (role) {
      case 'admin':
        return 'Administrátor';
      case 'employee':
        return 'Zamestnanec';
      case 'child':
        return 'Dieťa';
      default:
        return role ?? '';
    }
  }

  Gradient _getRoleGradient(String? role) {
    switch (role) {
      case 'admin':
        return const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFEF5350)]);
      case 'employee':
        return const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)]);
      case 'child':
        return AppTheme.primaryGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }
}








