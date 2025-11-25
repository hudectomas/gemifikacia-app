import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/season.dart';
import '../services/api_service.dart';
import '../config/theme.dart';

class SeasonSelector extends StatefulWidget {
  final Function(Season?) onSeasonChanged;
  
  const SeasonSelector({
    super.key,
    required this.onSeasonChanged,
  });

  @override
  State<SeasonSelector> createState() => _SeasonSelectorState();
}

class _SeasonSelectorState extends State<SeasonSelector> {
  List<Season> _seasons = [];
  Season? _selectedSeason;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    final seasons = await apiService.getSeasons();
    final activeSeason = await apiService.getActiveSeason();
    
    setState(() {
      _seasons = seasons;
      _selectedSeason = activeSeason;
      _isLoading = false;
    });
    
    widget.onSeasonChanged(_selectedSeason);
  }

  void _showSeasonPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
            Text('Vyber Sezónu', style: AppTheme.headingMedium),
            const SizedBox(height: 20),
            ..._seasons.map((season) => ListTile(
              leading: Icon(
                season.isActive ? Icons.check_circle : Icons.circle_outlined,
                color: season.isActive ? AppTheme.successColor : AppTheme.textSecondary,
              ),
              title: Text(
                season.name,
                style: TextStyle(
                  fontWeight: season.id == _selectedSeason?.id 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text('${season.year}'),
              selected: season.id == _selectedSeason?.id,
              selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() => _selectedSeason = season);
                widget.onSeasonChanged(season);
                Navigator.pop(context);
              },
              trailing: season.isActive 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AKTÍVNA',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
            )),
          ],
        ),
      ).animate()
        .slideY(begin: 1, end: 0, duration: 300.ms),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return InkWell(
      onTap: _showSeasonPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 10),
            Text(
              _selectedSeason?.name ?? 'Vyber sezónu',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}

