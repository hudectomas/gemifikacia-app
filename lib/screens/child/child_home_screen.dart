import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/stamp_provider.dart';
import '../../services/sync_service.dart';
import '../../config/theme.dart';
import '../tasks/tasks_screen.dart';
import '../stamps/stamps_screen.dart';
import '../settings/settings_screen.dart';
import '../qr/qr_scanner_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../../widgets/season_selector.dart';
import '../../models/season.dart';
import 'my_qr_code_screen.dart';
import 'my_seasons_screen.dart';
import '../../utils/helpers.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  bool _isRefreshing = false;
  Season? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<TaskProvider>().loadTasks(),
      context.read<StampProvider>().loadStamps(),
    ]);
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    
    final syncService = context.read<SyncService>();
    final (success, error) = await syncService.syncAll();
    
    if (success) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Dáta synchronizované! ✨'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
    
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final stampProvider = context.watch<StampProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background - Blue theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Light Blue shades
                stops: [0.0, 1.0],
              ),
            ),
          ),
          
          // Content
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                // App Bar with user info
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      Helpers.getInitials(authProvider.currentUser?.name ?? '?'),
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat())
                                    .shimmer(duration: 2000.ms, color: Colors.white24),
                                  
                                  const SizedBox(width: 15),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ahoj, ${authProvider.currentUser?.name ?? ""}! 👋',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '⭐ ${stampProvider.totalPoints} bodov',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
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
                
                // Content
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.scaffoldBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Card with confetti
                        _buildStatsCard(taskProvider, stampProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Quick Actions
                        Text('Rýchle Akcie', style: AppTheme.headingMedium),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        
                        const SizedBox(height: 24),
                        
                        // Recent Tasks
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🎯 Dostupné Úlohy', style: AppTheme.headingMedium),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TasksScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Všetky →',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTasksList(taskProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
                AppTheme.accentColor,
                AppTheme.successColor,
              ],
            ),
          ),
          
          // Refresh indicator
          if (_isRefreshing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(TaskProvider taskProvider, StampProvider stampProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD89B), Color(0xFFFF9A76)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9A76).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 32),
              const SizedBox(width: 10),
              Text(
                'Tvoj Pokrok',
                style: AppTheme.headingMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: '⭐',
                value: '${stampProvider.totalStamps}',
                label: 'Pečiatky',
              ),
              Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
              _buildStatItem(
                icon: '📋',
                value: '${taskProvider.totalTasks}',
                label: 'Úlohy',
              ),
              Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
              _buildStatItem(
                icon: '🎯',
                value: '${taskProvider.completionRate.toInt()}%',
                label: 'Hotovo',
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildStatItem({required String icon, required String value, required String label}) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          icon: Icons.task_alt,
          title: 'Všetky\nÚlohy',
          gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)]), // Deep Blue
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TasksScreen()),
            );
          },
        ).animate()
          .fadeIn(delay: 400.ms)
          .scale(delay: 400.ms),
        
        _buildActionCard(
          icon: Icons.stars,
          title: 'Moje\nPečiatky',
          gradient: const LinearGradient(colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)]), // Light Blue
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StampsScreen()),
            );
          },
        ).animate()
          .fadeIn(delay: 500.ms)
          .scale(delay: 500.ms),
        
        _buildActionCard(
          icon: Icons.qr_code_2,
          title: 'Môj QR\nKód',
          gradient: const LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF26C6DA)]), // Cyan
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyQrCodeScreen()),
            );
          },
        ).animate()
          .fadeIn(delay: 600.ms)
          .scale(delay: 600.ms),
        
        _buildActionCard(
          icon: Icons.leaderboard,
          title: 'Rebríček',
          gradient: const LinearGradient(colors: [Color(0xFF546E7A), Color(0xFF78909C)]), // Blue Grey
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
            );
          },
        ).animate()
          .fadeIn(delay: 700.ms)
          .scale(delay: 700.ms),
        
        _buildActionCard(
          icon: Icons.history,
          title: 'Moja\nHistória',
          gradient: const LinearGradient(colors: [Color(0xFF0097A7), Color(0xFF00BCD4)]), // Dark Cyan
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MySeasonsScreen()),
            );
          },
        ).animate()
          .fadeIn(delay: 800.ms)
          .scale(delay: 800.ms),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.2,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
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

  Widget _buildTasksList(TaskProvider taskProvider) {
    final tasks = taskProvider.tasks.take(4).toList();
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text('🎿', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'Žiadne úlohy',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Potiahnite dole pre obnovenie',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Show task details
                _showTaskDetails(task);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Emoji/Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: task.isCompleted
                            ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)])
                            : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          task.isCompleted ? '✅' : task.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: AppTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Points badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${task.points}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate()
          .fadeIn(delay: (800 + index * 100).ms)
          .slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  void _showTaskDetails(task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(task.emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(task.title, style: AppTheme.headingMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(task.description, style: AppTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '${task.points} bodov',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ).animate()
        .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut),
    );
  }
}

