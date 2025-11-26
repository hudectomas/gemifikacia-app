import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/season.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class SeasonManagementScreen extends StatefulWidget {
  const SeasonManagementScreen({super.key});

  @override
  State<SeasonManagementScreen> createState() => _SeasonManagementScreenState();
}

class _SeasonManagementScreenState extends State<SeasonManagementScreen> {
  List<Season> _seasons = [];
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
    
    setState(() {
      _seasons = seasons;
      _isLoading = false;
    });
  }

  Future<void> _showCreateSeasonDialog() async {
    final nameController = TextEditingController();
    final yearController = TextEditingController(text: DateTime.now().year.toString());
    final descController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 120));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nová Sezóna'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Názov',
                    hintText: 'napr. Zima 2025/2026',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Rok'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Dátum začiatku'),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Dátum konca'),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(endDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: startDate,
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Popis (voliteľný)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Zrušiť'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Zadaj názov sezóny')),
                  );
                  return;
                }
                Navigator.pop(context, true);
                _createSeason(
                  nameController.text,
                  int.tryParse(yearController.text) ?? DateTime.now().year,
                  startDate,
                  endDate,
                  descController.text,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Vytvoriť'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSeason(
    String name,
    int year,
    DateTime startDate,
    DateTime endDate,
    String description,
  ) async {
    final season = Season(
      id: 0,
      name: name,
      year: year,
      startDate: startDate,
      endDate: endDate,
      description: description.isEmpty ? null : description,
    );

    final apiService = context.read<ApiService>();
    final success = await apiService.createSeason(season);

    if (mounted) {
      if (success) {
        _loadSeasons();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sezóna vytvorená!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chyba pri vytváraní'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _activateSeason(Season season) async {
    final apiService = context.read<ApiService>();
    final success = await apiService.activateSeason(season.id);

    if (mounted) {
      if (success) {
        _loadSeasons();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${season.name} aktivovaná!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chyba pri aktivácii'),
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
        title: const Text('Správa Sezón'),
        backgroundColor: AppTheme.infoColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateSeasonDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _seasons.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _seasons.length,
                  itemBuilder: (context, index) {
                    final season = _seasons[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: season.isActive 
                            ? Border.all(color: AppTheme.successColor, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
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
                                          Text(
                                            season.name,
                                            style: AppTheme.headingSmall,
                                          ),
                                          if (season.isActive) ...[
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.successColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'AKTÍVNA',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${DateFormat('dd.MM.yyyy').format(season.startDate)} - ${DateFormat('dd.MM.yyyy').format(season.endDate)}',
                                        style: AppTheme.bodyMedium,
                                      ),
                                      if (season.description != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          season.description!,
                                          style: AppTheme.caption,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (!season.isActive)
                                  ElevatedButton(
                                    onPressed: () => _activateSeason(season),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                    ),
                                    child: const Text('Aktivovať'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideX(begin: 0.2, end: 0);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSeasonDialog,
        backgroundColor: AppTheme.infoColor,
        icon: const Icon(Icons.add),
        label: const Text('Nová Sezóna'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          Text(
            'Žiadne sezóny',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showCreateSeasonDialog,
            icon: const Icon(Icons.add),
            label: const Text('Vytvor prvú sezónu'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.infoColor),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }
}







