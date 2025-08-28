import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen_helpers.dart';

class TaskProgress extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const TaskProgress({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$completedTasks/$totalTasks Tasks done',
          style: HomeScreenHelpers.taskCountStyle,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: totalTasks > 0 ? completedTasks / totalTasks : 0,
          color: HomeScreenHelpers.primaryYellow,
          backgroundColor: Colors.grey[800],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}