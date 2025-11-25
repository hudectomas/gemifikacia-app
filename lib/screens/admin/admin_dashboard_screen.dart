import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../models/season.dart';
import '../../models/user.dart' as user_model;
import '../../config/theme.dart';
import '../../utils/helpers.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Season> _seasons = [];
  List<user_model.User> _allUsers = [];
  Map<int, Map<String, dynamic>> _seasonStats = {};
  Map<int, List<Map<String, dynamic>>> _seasonLeaderboards = {};
  bool _isLoading = true;
  Season? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    
    try {
      // Načítaj všetky sezóny
      final seasons = await apiService.getSeasons();
      
      // Načítaj všetkých používateľov
      final users = await apiService.getUsers();
      
      // Pre každú sezónu načítaj štatistiky a rebríček
      final stats = <int, Map<String, dynamic>>{};
      final leaderboards = <int, List<Map<String, dynamic>>>{};
      
      for (final season in seasons) {
        final seasonStats = await apiService.getSeasonStatistics(season.id);
        stats[season.id] = seasonStats;
        
        final leaderboard = await apiService.getLeaderboard(seasonId: season.id);
        leaderboards[season.id] = leaderboard;
      }
      
      setState(() {
        _seasons = seasons;
        _allUsers = users;
        _seasonStats = stats;
        _seasonLeaderboards = leaderboards;
        _selectedSeason = seasons.firstWhere((s) => s.isActive, orElse: () => seasons.first);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri načítaní dát: $e'),
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
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Sezóny'),
            Tab(icon: Icon(Icons.people), text: 'Používatelia'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Rebríčky'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSeasonsTab(),
                _buildUsersTab(),
                _buildLeaderboardsTab(),
              ],
            ),
    );
  }

  // Tab 1: Sezóny Overview
  Widget _buildSeasonsTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '📊 Celkový Prehľad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOverviewStat('🗓️', _seasons.length.toString(), 'Sezón'),
                    _buildOverviewStat('👥', _allUsers.length.toString(), 'Užívateľov'),
                    _buildOverviewStat('🎯', _allUsers.where((u) => u.role == 'child').length.toString(), 'Detí'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(),
          
          const SizedBox(height: 24),
          
          // Seasons list
          Text('Všetky Sezóny', style: AppTheme.headingLarge),
          const SizedBox(height: 16),
          
          if (_seasons.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Žiadne sezóny', style: AppTheme.headingMedium),
                ],
              ),
            )
          else
            ..._seasons.map((season) => _buildAdminSeasonCard(season)).toList(),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSeasonCard(Season season) {
    final stats = _seasonStats[season.id];
    final totalUsers = stats?['total_users'] ?? 0;
    final totalStamps = stats?['total_stamps'] ?? 0;
    final totalPoints = stats?['total_points'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: season.isActive
            ? const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)]) // Deep Blue for active
            : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (season.isActive ? AppTheme.successColor : Colors.grey).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showSeasonDetails(season, stats),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  season.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (season.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '🌟 AKTÍVNA',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(season.startDate)} - ${_formatDate(season.endDate)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildSeasonStatItem('👥', 'Účastníci', '$totalUsers'),
                    ),
                    Expanded(
                      child: _buildSeasonStatItem('📝', 'Pečiatky', '$totalStamps'),
                    ),
                    Expanded(
                      child: _buildSeasonStatItem('⭐', 'Body', '$totalPoints'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: _seasons.indexOf(season) * 100)).fadeIn().slideX(begin: 0.2, end: 0);
  }

  Widget _buildSeasonStatItem(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Users Overview
  Widget _buildUsersTab() {
    final children = _allUsers.where((u) => u.role == 'child').toList();
    final employees = _allUsers.where((u) => u.role == 'employee').toList();
    final admins = _allUsers.where((u) => u.role == 'admin').toList();
    
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserSection('👶 Deti', children, Colors.blue),
          const SizedBox(height: 20),
          _buildUserSection('👨‍💼 Zamestnanci', employees, Colors.orange),
          const SizedBox(height: 20),
          _buildUserSection('👑 Administrátori', admins, Colors.red),
        ],
      ),
    );
  }

  Widget _buildUserSection(String title, List<user_model.User> users, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTheme.headingLarge),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${users.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (users.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Žiadni používatelia'),
            ),
          )
        else
          ...users.map((user) => _buildUserCard(user, color)).toList(),
      ],
    );
  }

  Widget _buildUserCard(user_model.User user, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            Helpers.getInitials(user.name),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.email),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  // Tab 3: Leaderboards
  Widget _buildLeaderboardsTab() {
    return Column(
      children: [
        // Season selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: DropdownButtonFormField<Season>(
            value: _selectedSeason,
            decoration: const InputDecoration(
              labelText: 'Vyber sezónu',
              prefixIcon: Icon(Icons.calendar_month),
            ),
            items: _seasons.map((season) {
              return DropdownMenuItem(
                value: season,
                child: Row(
                  children: [
                    Text(season.name),
                    if (season.isActive) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '🌟',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (season) {
              setState(() => _selectedSeason = season);
            },
          ),
        ),
        
        // Leaderboard
        Expanded(
          child: _selectedSeason == null
              ? const Center(child: Text('Vyber sezónu'))
              : _buildLeaderboardList(_selectedSeason!),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(Season season) {
    final leaderboard = _seasonLeaderboards[season.id] ?? [];
    
    if (leaderboard.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Žiadne údaje pre túto sezónu'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        final rank = index + 1;
        
        Color rankColor;
        String medal;
        
        if (rank == 1) {
          rankColor = const Color(0xFFFFD700);
          medal = '🥇';
        } else if (rank == 2) {
          rankColor = const Color(0xFFC0C0C0);
          medal = '🥈';
        } else if (rank == 3) {
          rankColor = const Color(0xFFCD7F32);
          medal = '🥉';
        } else {
          rankColor = Colors.grey;
          medal = '';
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: rank <= 3 ? Border.all(color: rankColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: rankColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: SizedBox(
              width: 50,
              child: Row(
                children: [
                  if (medal.isNotEmpty)
                    Text(medal, style: const TextStyle(fontSize: 24))
                  else
                    CircleAvatar(
                      backgroundColor: rankColor,
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            title: Text(
              entry['user_name'] ?? 'Unknown',
              style: TextStyle(
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.w600,
                fontSize: rank <= 3 ? 16 : 15,
              ),
            ),
            subtitle: Text('${entry['total_stamps'] ?? 0} pečiatok'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '⭐ ${entry['total_points'] ?? 0}',
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
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Máj', 'Jún', 'Júl', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  void _showSeasonDetails(Season season, Map<String, dynamic>? stats) {
    // TODO: Implement detailed season modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(season.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Účastníci: ${stats?['total_users'] ?? 0}'),
            Text('Pečiatky: ${stats?['total_stamps'] ?? 0}'),
            Text('Body: ${stats?['total_points'] ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavrieť'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(user_model.User user) {
    // TODO: Implement detailed user modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Rola: ${user.role}'),
            Text('Vytvorené: ${_formatDate(user.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavrieť'),
          ),
        ],
      ),
    );
  }
}

