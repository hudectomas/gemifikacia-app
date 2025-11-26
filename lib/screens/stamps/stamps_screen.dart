import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/stamp_provider.dart';
import '../../config/theme.dart';

class StampsScreen extends StatelessWidget {
  const StampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stampProvider = context.watch<StampProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf093fb), AppTheme.scaffoldBackground],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with stats
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
                          '⭐ Moje Pečiatky',
                          style: AppTheme.headingLarge.copyWith(color: Colors.white, fontSize: 26),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('⭐', '${stampProvider.totalStamps}', 'Pečiatky'),
                          Container(width: 1, height: 50, color: Colors.grey[300]),
                          _buildStatColumn('🏆', '${stampProvider.totalPoints}', 'Body'),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stamps list
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: stampProvider.stamps.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: stampProvider.stamps.length,
                          itemBuilder: (context, index) {
                            final stamp = stampProvider.stamps[index];
                            
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Checkmark
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 32),
                                    ),
                                    
                                    const SizedBox(width: 16),
                                    
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stamp.task?.title ?? 'Úloha',
                                            style: AppTheme.bodyLarge.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('dd.MM.yyyy HH:mm').format(stamp.stampedAt),
                                            style: AppTheme.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Points badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.goldGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '+${stamp.task?.points ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎖️', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          Text(
            'Zatiaľ žiadne pečiatky',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            'Začni plniť úlohy a zbieraj pečiatky!',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ).animate()
        .fadeIn(duration: 800.ms)
        .scale(),
    );
  }
}









