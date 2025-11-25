class TaskModel {
  final int id;
  final String title;
  final String description;
  final String? icon;
  final int points;
  final String? category;
  final bool isActive;
  final int order;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    required this.points,
    this.category,
    this.isActive = true,
    this.order = 0,
    this.isCompleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
      points: json['points'] as int,
      category: json['category'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'category': category,
      'is_active': isActive,
      'order': order,
      'is_completed': isCompleted,
    };
  }

  String get categoryDisplay {
    switch (category) {
      case 'ski_school':
        return 'Lyžiarska škola';
      case 'buffet':
        return 'Bufet';
      case 'activity':
        return 'Aktivita';
      case 'safety':
        return 'Bezpečnosť';
      default:
        return 'Ostatné';
    }
  }

  String get emoji {
    switch (category) {
      case 'ski_school':
        return '⛷️';
      case 'buffet':
        return '☕';
      case 'activity':
        return '🎯';
      case 'safety':
        return '🛡️';
      default:
        return '✨';
    }
  }
}






