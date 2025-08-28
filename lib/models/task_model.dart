import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'task_model.g.dart';

// Task priority levels
enum TaskPriority { low, medium, high, critical }

// Task repeat types
enum TaskRepeatType { none, daily, weekly, monthly, custom }

// Main task data model
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  // Basic task information
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String time;

  @HiveField(3)
  String tag;

  // Task status
  @HiveField(4)
  bool isDone;

  @HiveField(5)
  bool isPinned;

  // User association
  @HiveField(6)
  String? userEmail;

  // Date and time fields
  @HiveField(7)
  DateTime? startDate;

  @HiveField(8)
  DateTime? dueDate;

  @HiveField(9)
  String? startTimeString;

  @HiveField(10)
  String? dueTimeString;

  @HiveField(11)
  int? estimatedDurationMinutes;

  // Task configuration
  @HiveField(12)
  TaskPriority priority;

  @HiveField(13)
  List<String> reminders;

  @HiveField(14)
  TaskRepeatType repeatType;

  @HiveField(15)
  Map<String, dynamic>? repeatConfig;

  @HiveField(16)
  DateTime? repeatEndDate;

  // Task components
  @HiveField(17)
  List<SubTask> subtasks;

  @HiveField(18)
  List<String> attachmentPaths;

  // Timestamps
  @HiveField(19)
  DateTime createdAt;

  @HiveField(20)
  DateTime updatedAt;

  // Constructor
  TaskModel({
    required this.title,
    required this.description,
    required this.time,
    required this.tag,
    this.isDone = false,
    this.isPinned = false,
    this.userEmail,
    this.startDate,
    this.dueDate,
    TimeOfDay? startTime,
    TimeOfDay? dueTime,
    this.estimatedDurationMinutes,
    this.priority = TaskPriority.medium,
    this.reminders = const [],
    this.repeatType = TaskRepeatType.none,
    this.repeatConfig,
    this.repeatEndDate,
    this.subtasks = const [],
    this.attachmentPaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.startTimeString = startTime != null ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}' : null,
    this.dueTimeString = dueTime != null ? '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}' : null,
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  // Computed properties
  bool get hasDateRange => startDate != null && dueDate != null;
  bool get hasTimeRange => startTimeString != null && dueTimeString != null;
  
  // Time conversion getters
  TimeOfDay? get startTime {
    if (startTimeString == null) return null;
    final parts = startTimeString!.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return null;
  }
  
  TimeOfDay? get dueTime {
    if (dueTimeString == null) return null;
    final parts = dueTimeString!.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return null;
  }
  
  // Status getters
  bool get isRecurring => repeatType != TaskRepeatType.none;
  bool get hasSubtasks => subtasks.isNotEmpty;
  bool get hasAttachments => attachmentPaths.isNotEmpty;
  bool get hasReminders => reminders.isNotEmpty;
  
  // Progress tracking
  int get completedSubtasksCount => subtasks.where((task) => task.isCompleted).length;
  double get subtaskProgress => subtasks.isEmpty ? 0.0 : completedSubtasksCount / subtasks.length;

  // Update task method
  void update({
    String? title,
    String? description,
    String? time,
    String? tag,
    bool? isDone,
    bool? isPinned,
    DateTime? startDate,
    DateTime? dueDate,
    TimeOfDay? startTime,
    TimeOfDay? dueTime,
    int? estimatedDurationMinutes,
    TaskPriority? priority,
    List<String>? reminders,
    TaskRepeatType? repeatType,
    Map<String, dynamic>? repeatConfig,
    DateTime? repeatEndDate,
    List<SubTask>? subtasks,
    List<String>? attachmentPaths,
  }) {
    if (title != null) this.title = title;
    if (description != null) this.description = description;
    if (time != null) this.time = time;
    if (tag != null) this.tag = tag;
    if (isDone != null) this.isDone = isDone;
    if (isPinned != null) this.isPinned = isPinned;
    if (startDate != null) this.startDate = startDate;
    if (dueDate != null) this.dueDate = dueDate;
    if (startTime != null) this.startTimeString = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    if (dueTime != null) this.dueTimeString = '${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}';
    if (estimatedDurationMinutes != null) this.estimatedDurationMinutes = estimatedDurationMinutes;
    if (priority != null) this.priority = priority;
    if (reminders != null) this.reminders = reminders;
    if (repeatType != null) this.repeatType = repeatType;
    if (repeatConfig != null) this.repeatConfig = repeatConfig;
    if (repeatEndDate != null) this.repeatEndDate = repeatEndDate;
    if (subtasks != null) this.subtasks = subtasks;
    if (attachmentPaths != null) this.attachmentPaths = attachmentPaths;
    
    this.updatedAt = DateTime.now();
  }
}

// Subtask data model
@HiveType(typeId: 1)
class SubTask {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  int order;

  @HiveField(3)
  DateTime createdAt;

  SubTask({
    required this.title,
    this.isCompleted = false,
    required this.order,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Toggle completion status
  void toggle() {
    isCompleted = !isCompleted;
  }
}


