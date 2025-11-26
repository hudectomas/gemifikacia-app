import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    final leaderboard = await apiService.getLeaderboard(limit: 20);
    
    setState(() {
      _leaderboard = leaderboard;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFfa709a), AppTheme.scaffoldBackground],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          '🏆 Rebríček',
                          style: AppTheme.headingLarge.copyWith(color: Colors.white, fontSize: 28),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                          onPressed: _loadLeaderboard,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Leaderboard
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _leaderboard.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _leaderboard.length,
                              itemBuilder: (context, index) {
                                final entry = _leaderboard[index];
                                final rank = index + 1;
                                
                                return _buildLeaderboardCard(
                                  rank: rank,
                                  name: entry['name'] as String? ?? 'Unknown',
                                  points: entry['total_points'] as int? ?? 0,
                                  stampsCount: entry['stamps_count'] as int? ?? 0,
                                  index: index,
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String name,
    required int points,
    required int stampsCount,
    required int index,
  }) {
    Color getRankColor() {
      switch (rank) {
        case 1:
          return const Color(0xFFFFD700); // Gold
        case 2:
          return const Color(0xFFC0C0C0); // Silver
        case 3:
          return const Color(0xFFCD7F32); // Bronze
        default:
          return AppTheme.primaryColor;
      }
    }

    IconData getRankIcon() {
      switch (rank) {
        case 1:
          return Icons.emoji_events;
        case 2:
          return Icons.emoji_events_outlined;
        case 3:
          return Icons.military_tech;
        default:
          return Icons.star_outline;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: rank <= 3 ? Border.all(color: getRankColor(), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(rank <= 3 ? 0.1 : 0.05),
            blurRadius: rank <= 3 ? 15 : 10,
            offset: Offset(0, rank <= 3 ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: getRankColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: getRankColor().withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: rank <= 3
                    ? Icon(getRankIcon(), color: Colors.white, size: 28)
                    : Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$stampsCount pečiatok',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: (index * 50).ms)
      .slideX(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          Text(
            'Zatiaľ žiadne dáta',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            'Rebríček sa zobrazí keď deti začnú zbierať pečiatky',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }
}







