import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/task_model.dart';

class HomeScreenHelpers {
  static const Map<String, Color> tagColors = {
    'Work': Colors.red,
    'Personal': Colors.blue,
    'Shopping': Colors.green,
    'Health': Colors.orange,
    'All': Colors.grey,
  };

  static const List<String> defaultCategories = [
    'All',
    'Work',
    'Personal',
    'Shopping',
    'Health',
  ];

  static const Color primaryYellow = Color(0xFFF7DF27);
  static const Color backgroundColor = Colors.black;
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColor = Colors.white;

  static TextStyle get titleStyle => GoogleFonts.poppins(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get selectedTitleStyle => GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get descriptionStyle => GoogleFonts.poppins(
        color: Colors.white54,
        fontSize: 14,
      );

  static TextStyle get taskCountStyle => GoogleFonts.poppins(
        color: textColor,
        fontSize: 16,
      );

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String formatDateTime(DateTime date, TimeOfDay time) {
    final dateStr = formatDate(date);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.critical:
        return Colors.purple;
    }
  }

  static String getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  static String getRepeatDisplayText(TaskRepeatType repeatType, Map<String, dynamic>? repeatConfig) {
    switch (repeatType) {
      case TaskRepeatType.none:
        return 'No repeat';
      case TaskRepeatType.daily:
        return 'Daily';
      case TaskRepeatType.weekly:
        return 'Weekly';
      case TaskRepeatType.monthly:
        return 'Monthly';
      case TaskRepeatType.custom:
        if (repeatConfig != null && repeatConfig['interval'] != null) {
          final interval = repeatConfig['interval'];
          final unit = repeatConfig['unit'] ?? 'days';
          return 'Every $interval $unit';
        }
        return 'Custom';
    }
  }

  static String getTimeDisplayText(TimeOfDay? startTime, TimeOfDay? dueTime) {
    if (startTime == null && dueTime == null) {
      return 'No time set';
    } else if (startTime != null && dueTime != null) {
      return '${formatTime(startTime)} → ${formatTime(dueTime)}';
    } else if (startTime != null) {
      return 'From ${formatTime(startTime)}';
    } else {
      return 'Until ${formatTime(dueTime!)}';
    }
  }

  static BoxDecoration getCategoryDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected ? primaryYellow : Colors.grey[900],
      borderRadius: BorderRadius.circular(20),
    );
  }

  static BoxDecoration getTaskCardDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected ? primaryYellow.withOpacity(0.2) : cardBackgroundColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primaryYellow,
        width: isSelected ? 2.0 : 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryYellow.withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          blurRadius: 6,
          spreadRadius: 2,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static BoxDecoration getSelectionIndicatorDecoration(bool isSelected) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: isSelected ? primaryYellow : Colors.transparent,
      border: Border.all(color: primaryYellow, width: 2),
    );
  }
}
