import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../services/sync_service.dart';
import '../../config/theme.dart';
import '../settings/settings_screen.dart';
import '../qr/qr_scanner_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import 'task_management_screen.dart';
import 'user_management_screen.dart';
import 'season_management_screen.dart';
import 'admin_dashboard_screen.dart';
import '../employee/manual_stamp_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _checkOnline();
  }

  Future<void> _checkOnline() async {
    final syncService = context.read<SyncService>();
    final online = await syncService.isOnline();
    setState(() => _isOnline = online);
  }

  Future<void> _handleSync() async {
    final syncService = context.read<SyncService>();
    final (success, error) = await syncService.syncAll();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Synchronizácia úspešná!' : error ?? 'Chyba'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      if (success) {
        setState(() => _isOnline = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vitaj, ${authProvider.currentUser?.name ?? ""}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isOnline ? 'Online' : 'Offline',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 30),
              
              Text('Správa Systému', style: AppTheme.headingMedium),
              const SizedBox(height: 16),
              
              // Management Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _buildManagementCard(
                    icon: Icons.assignment,
                    title: 'Úlohy',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),
                  
                  _buildManagementCard(
                    icon: Icons.people,
                    title: 'Používatelia',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserManagementScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
                  
                  _buildManagementCard(
                    icon: Icons.calendar_today,
                    title: 'Sezóny',
                    color: const Color(0xFF00BCD4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SeasonManagementScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),
                  
                  _buildManagementCard(
                    icon: Icons.bar_chart,
                    title: 'Rebríček',
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
                  
                  _buildManagementCard(
                    icon: Icons.qr_code,
                    title: 'Skenovať',
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
                  
                  _buildManagementCard(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 700.ms).scale(delay: 700.ms),
                  
                  _buildManagementCard(
                    icon: Icons.edit,
                    title: 'Manuálne\nPečiatka',
                    color: const Color(0xFFFF5722),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManualStampScreen()),
                      );
                    },
                  ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Sync Card
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Synchronizácia', style: AppTheme.headingSmall),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSync,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sync, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Synchronizovať dáta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

