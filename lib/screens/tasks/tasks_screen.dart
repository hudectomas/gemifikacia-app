import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/task_provider.dart';
import '../../config/theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), AppTheme.scaffoldBackground],
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
                          '🎯 Úlohy',
                          style: AppTheme.headingLarge.copyWith(color: Colors.white, fontSize: 28),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: '🔍 Hľadať úlohu...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ).animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: -0.2, end: 0),
                  ],
                ),
              ),
              
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: const [
                    Tab(child: Text('Všetky', style: TextStyle(fontWeight: FontWeight.w600))),
                    Tab(child: Text('Dokončené', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Task list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(taskProvider.tasks),
                    _buildTaskList(taskProvider.completedTasks),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List tasks) {
    final filteredTasks = tasks.where((task) {
      if (_searchQuery.isEmpty) return true;
      return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             task.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎿', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'Žiadne úlohy',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        
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
                // Icon/Emoji
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: task.isCompleted
                        ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)])
                        : const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      task.isCompleted ? '✅' : task.emoji,
                      style: const TextStyle(fontSize: 32),
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: AppTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(task.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.categoryDisplay,
                          style: TextStyle(
                            color: _getCategoryColor(task.category),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Points
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 20)),
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
        ).animate()
          .fadeIn(delay: (index * 100).ms)
          .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ski_school':
        return AppTheme.skiSchoolColor;
      case 'buffet':
        return AppTheme.buffetColor;
      case 'activity':
        return AppTheme.activityColor;
      case 'safety':
        return AppTheme.safetyColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}






