import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/task_model.dart';
import '../../services/api_service.dart';
import '../../providers/task_provider.dart';
import '../../config/theme.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskProvider>().loadTasks();
  }

  Future<void> _showTaskDialog({TaskModel? task}) async {
    final isEdit = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    final pointsController = TextEditingController(text: task?.points.toString() ?? '10');
    String category = task?.category ?? 'ski_school';
    final orderController = TextEditingController(text: task?.order.toString() ?? '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? 'Upraviť úlohu' : 'Nová úloha'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Názov'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Popis'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(labelText: 'Body'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategória'),
                  items: const [
                    DropdownMenuItem(value: 'ski_school', child: Text('⛷️ Lyžiarska škola')),
                    DropdownMenuItem(value: 'buffet', child: Text('☕ Bufet')),
                    DropdownMenuItem(value: 'activity', child: Text('🎯 Aktivita')),
                    DropdownMenuItem(value: 'safety', child: Text('🛡️ Bezpečnosť')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Poradie'),
                  keyboardType: TextInputType.number,
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
              onPressed: () async {
                if (titleController.text.isEmpty || descController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vyplň všetky povinné polia')),
                  );
                  return;
                }

                final newTask = TaskModel(
                  id: task?.id ?? 0,
                  title: titleController.text,
                  description: descController.text,
                  points: int.tryParse(pointsController.text) ?? 10,
                  category: category,
                  order: int.tryParse(orderController.text) ?? 0,
                  isActive: true,
                );

                Navigator.pop(context, true);
                _saveTask(newTask, isEdit);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: Text(isEdit ? 'Uložiť' : 'Vytvoriť'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask(TaskModel task, bool isEdit) async {
    final apiService = context.read<ApiService>();
    final success = isEdit
        ? await apiService.updateTask(task.id, task)
        : await apiService.createTask(task);

    if (mounted) {
      if (success) {
        await context.read<TaskProvider>().loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Úloha upravená!' : 'Úloha vytvorená!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chyba pri ukladaní'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Vymazať úlohu?'),
        content: Text('Naozaj chceš vymazať "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Vymazať'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final apiService = context.read<ApiService>();
      final success = await apiService.deleteTask(task.id);

      if (mounted) {
        if (success) {
          await context.read<TaskProvider>().loadTasks();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Úloha vymazaná'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chyba pri mazaní'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Správa Úloh'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTaskDialog(),
          ),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(task.emoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(task.description, maxLines: 2),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.categoryDisplay,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('⭐ ${task.points} bodov', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 10),
                                  Text('Upraviť'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                                  SizedBox(width: 10),
                                  Text('Vymazať', style: TextStyle(color: AppTheme.errorColor)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showTaskDialog(task: task);
                            } else if (value == 'delete') {
                              _deleteTask(task);
                            }
                          },
                        ),
                      ),
                    ).animate()
                      .fadeIn(delay: (index * 50).ms)
                      .slideX(begin: 0.2, end: 0);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Nová úloha'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          Text(
            'Žiadne úlohy',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showTaskDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Vytvor prvú úlohu'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }
}








