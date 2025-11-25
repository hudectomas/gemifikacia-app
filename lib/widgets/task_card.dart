import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_model.dart';
import '../config/theme.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final int? animationDelay;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
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
                        ? const LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF26C6DA)]) // Cyan for completed
                        : _getCategoryGradient(task.category),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (task.isCompleted ? const Color(0xFF00ACC1) : _getCategoryColor(task.category))
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        style: AppTheme.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Points badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        '${task.points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
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
      .fadeIn(delay: Duration(milliseconds: animationDelay ?? 0))
      .slideX(begin: 0.2, end: 0);
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

  Gradient _getCategoryGradient(String? category) {
    final color = _getCategoryColor(category);
    return LinearGradient(
      colors: [color, color.withOpacity(0.7)],
    );
  }
}

