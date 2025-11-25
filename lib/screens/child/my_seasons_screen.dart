import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../models/season.dart';
import '../../config/theme.dart';

class MySeasonsScreen extends StatefulWidget {
  const MySeasonsScreen({super.key});

  @override
  State<MySeasonsScreen> createState() => _MySeasonsScreenState();
}

class _MySeasonsScreenState extends State<MySeasonsScreen> {
  List<Season> _seasons = [];
  Map<int, Map<String, dynamic>> _seasonStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    
    try {
      // Načítaj všetky sezóny
      final seasons = await apiService.getSeasons();
      
      // Pre každú sezónu načítaj štatistiky
      final stats = <int, Map<String, dynamic>>{};
      for (final season in seasons) {
        final seasonStats = await apiService.getSeasonStatistics(season.id);
        stats[season.id] = seasonStats;
      }
      
      setState(() {
        _seasons = seasons;
        _seasonStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri načítaní sezón: $e'),
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
        title: const Text('Moja História'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _seasons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Žiadne sezóny',
                        style: AppTheme.headingMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSeasons,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _seasons.length,
                    itemBuilder: (context, index) {
                      final season = _seasons[index];
                      final stats = _seasonStats[season.id];
                      
                      return _buildSeasonCard(season, stats)
                          .animate(delay: Duration(milliseconds: index * 100))
                          .fadeIn()
                          .slideX(begin: 0.2, end: 0);
                    },
                  ),
                ),
    );
  }

  Widget _buildSeasonCard(Season season, Map<String, dynamic>? stats) {
    final totalStamps = stats?['total_stamps'] ?? 0;
    final totalPoints = stats?['total_points'] ?? 0;
    final completedTasks = stats?['completed_tasks'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: season.isActive
            ? const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              )
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (season.isActive ? AppTheme.successColor : Colors.grey)
                .withOpacity(0.3),
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
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
                
                const SizedBox(height: 20),
                
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: '📝',
                        label: 'Pečiatky',
                        value: '$totalStamps',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: '⭐',
                        label: 'Body',
                        value: '$totalPoints',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: '✅',
                        label: 'Úlohy',
                        value: '$completedTasks',
                      ),
                    ),
                  ],
                ),
                
                if (season.description != null && season.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            season.description!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Máj', 'Jún',
      'Júl', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  void _showSeasonDetails(Season season, Map<String, dynamic>? stats) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              season.name,
              style: AppTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(season.startDate)} - ${_formatDate(season.endDate)}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Detailed stats
            if (stats != null) ...[
              _buildDetailRow('📝 Celkový počet pečiatok', '${stats['total_stamps']}'),
              _buildDetailRow('⭐ Celkový počet bodov', '${stats['total_points']}'),
              _buildDetailRow('✅ Splnené úlohy', '${stats['completed_tasks']}'),
              _buildDetailRow('🏆 Tvoje poradie', stats['user_rank']?.toString() ?? 'N/A'),
            ],
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Zavrieť',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

