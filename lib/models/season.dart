class Season {
  final int id;
  final String name;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? description;

  Season({
    required this.id,
    required this.name,
    required this.year,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    this.description,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as int,
      name: json['name'] as String,
      year: json['year'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_active': isActive,
      'description': description,
    };
  }
}








