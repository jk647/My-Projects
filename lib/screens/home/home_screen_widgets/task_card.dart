import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/task_model.dart';
import '../../../constants/tap_feedback_helpers.dart';
import 'home_screen_helpers.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final int index;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleDone;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: HomeScreenHelpers.getTaskCardDecoration(isSelected),
        child: Row(
          children: [
            TapFeedbackHelpers.feedbackIconButton(
              context: context,
              onPressed: onToggleDone,
              icon: Icon(
                task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isDone ? HomeScreenHelpers.primaryYellow : Colors.white,
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: HomeScreenHelpers.primaryYellow.withOpacity(0.3),
              size: 48,
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                      ),
                      if (task.isPinned && !isSelectionMode)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.push_pin,
                            color: HomeScreenHelpers.primaryYellow,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  
                  if (task.description.isNotEmpty && task.description.length <= 50)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description,
                        style: HomeScreenHelpers.descriptionStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      if (task.startTime != null || task.dueTime != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white54,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              HomeScreenHelpers.getTimeDisplayText(task.startTime, task.dueTime),
                              style: HomeScreenHelpers.descriptionStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      
                      const SizedBox(width: 12),
                      
                      if (task.tag.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: HomeScreenHelpers.tagColors[task.tag]?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.tag,
                            style: TextStyle(
                              color: HomeScreenHelpers.tagColors[task.tag] ?? Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      const Spacer(),
                      
                      if (task.priority != TaskPriority.medium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: HomeScreenHelpers.getPriorityColor(task.priority).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            HomeScreenHelpers.getPriorityText(task.priority),
                            style: TextStyle(
                              color: HomeScreenHelpers.getPriorityColor(task.priority),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      if (task.attachmentPaths.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.attach_file,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      
                      if (task.repeatType != TaskRepeatType.none)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.repeat,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (isSelectionMode)
              Container(
                width: 24,
                height: 24,
                decoration: HomeScreenHelpers.getSelectionIndicatorDecoration(isSelected),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 16,
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
