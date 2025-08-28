import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/task_model.dart';
import '../../../constants/tap_feedback_helpers.dart';
import 'home_screen_helpers.dart';

class TaskList extends StatelessWidget {
  final List<TaskModel> visibleTasks;
  final bool isSelectionMode;
  final Set<int> selectedTasks;
  final Function(TaskModel) onTaskTap;
  final Function(TaskModel) onTaskLongPress;
  final Function(TaskModel) onTaskDelete;
  final Function(TaskModel) onTaskToggleDone;

  const TaskList({
    super.key,
    required this.visibleTasks,
    required this.isSelectionMode,
    required this.selectedTasks,
    required this.onTaskTap,
    required this.onTaskLongPress,
    required this.onTaskDelete,
    required this.onTaskToggleDone,
  });

  String _getTimeDisplay(TaskModel task) {
    if (task.startTime != null && task.dueTime != null) {
      final startTime = HomeScreenHelpers.formatTime(task.startTime!);
      final dueTime = HomeScreenHelpers.formatTime(task.dueTime!);
      return '$startTime - $dueTime';
    }
    else if (task.dueTime != null) {
      return HomeScreenHelpers.formatTime(task.dueTime!);
    }
    else if (task.startTime != null) {
      return HomeScreenHelpers.formatTime(task.startTime!);
    }
    else {
      return task.time.isNotEmpty ? task.time : 'No time set';
    }
  }

  @override
  Widget build(BuildContext context) {
    return visibleTasks.isEmpty
        ? Center(
            child: Text(
              'No tasks added yet.',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          )
        : ListView.builder(
            itemCount: visibleTasks.length,
            itemBuilder: (context, index) {
              final task = visibleTasks[index];
              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (_) async {
                  onTaskDelete(task);
                },
                child: GestureDetector(
                  onTap: () => onTaskTap(task),
                  onLongPress: () => onTaskLongPress(task),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    height: 90,
                    decoration: BoxDecoration(
                      color: selectedTasks.contains(index)
                          ? const Color(0xFFF7DF27).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedTasks.contains(index)
                            ? const Color(0xFFF7DF27)
                            : const Color(0xFFF7DF27),
                        width: selectedTasks.contains(index) ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7DF27).withOpacity(0.4),
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
                    ),
                    child: Row(
                      children: [
                        TapFeedbackHelpers.feedbackIconButton(
                          context: context,
                          onPressed: () => onTaskToggleDone(task),
                          icon: Icon(
                            task.isDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task.isDone
                                ? const Color(0xFFF7DF27)
                                : Colors.white,
                          ),
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
                          size: 48,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: task.isDone
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (task.isPinned)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      child: const Icon(
                                        Icons.push_pin,
                                        color: Color(0xFFF7DF27),
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimeDisplay(task),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.label,
                                    size: 16,
                                    color: HomeScreenHelpers.tagColors[task.tag] ??
                                        Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.tag,
                                    style: TextStyle(
                                      color: HomeScreenHelpers.tagColors[task.tag] ??
                                          Colors.grey[400],
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedTasks.contains(index)
                                  ? const Color(0xFFF7DF27)
                                  : Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFFF7DF27),
                                width: 2,
                              ),
                            ),
                            child: selectedTasks.contains(index)
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
                ),
              );
            },
          );
  }
}