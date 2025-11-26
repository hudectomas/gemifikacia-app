import 'task_model.dart';
import 'user.dart';

class UserStamp {
  final int id;
  final int userId;
  final int taskId;
  final int stampedBy;
  final DateTime stampedAt;
  final String? qrCodeUsed;
  final bool synced;
  final String? notes;
  TaskModel? task;
  User? employee;

  UserStamp({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.stampedBy,
    required this.stampedAt,
    this.qrCodeUsed,
    this.synced = false,
    this.notes,
    this.task,
    this.employee,
  });

  factory UserStamp.fromJson(Map<String, dynamic> json) {
    return UserStamp(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      taskId: json['task_id'] as int,
      stampedBy: json['stamped_by'] as int,
      stampedAt: DateTime.parse(json['stamped_at'] as String),
      qrCodeUsed: json['qr_code_used'] as String?,
      synced: json['synced'] as bool? ?? false,
      notes: json['notes'] as String?,
      task: json['task'] != null 
          ? TaskModel.fromJson(json['task'] as Map<String, dynamic>)
          : null,
      employee: json['employee'] != null
          ? User.fromJson(json['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'stamped_by': stampedBy,
      'stamped_at': stampedAt.toIso8601String(),
      'qr_code_used': qrCodeUsed,
      'synced': synced,
      'notes': notes,
    };
  }
}








