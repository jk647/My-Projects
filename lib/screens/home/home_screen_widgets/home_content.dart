import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import 'task_progress.dart';
import 'category_selector.dart';
import 'task_list.dart';

class HomeContent extends StatelessWidget {
  final List<TaskModel> userTasks;
  final List<TaskModel> visibleTasks;
  final List<String> allCategories;
  final int selectedCategory;
  final bool isSelectionMode;
  final Set<int> selectedTasks;
  final Function(int) onCategorySelected;
  final VoidCallback onAddCategory;
  final Function(TaskModel) onTaskTap;
  final Function(TaskModel) onTaskLongPress;
  final Function(TaskModel) onTaskDelete;
  final Function(TaskModel) onTaskToggleDone;

  const HomeContent({
    super.key,
    required this.userTasks,
    required this.visibleTasks,
    required this.allCategories,
    required this.selectedCategory,
    required this.isSelectionMode,
    required this.selectedTasks,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.onTaskTap,
    required this.onTaskLongPress,
    required this.onTaskDelete,
    required this.onTaskToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = userTasks.where((task) => task.isDone).length;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: isSelectionMode ? kToolbarHeight + MediaQuery.of(context).padding.top + 10 : 10,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskProgress(
            completedTasks: completedTasks,
            totalTasks: userTasks.length,
          ),
          
          CategorySelector(
            allCategories: allCategories,
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
            onAddCategory: onAddCategory,
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: TaskList(
              visibleTasks: visibleTasks,
              isSelectionMode: isSelectionMode,
              selectedTasks: selectedTasks,
              onTaskTap: onTaskTap,
              onTaskLongPress: onTaskLongPress,
              onTaskDelete: onTaskDelete,
              onTaskToggleDone: onTaskToggleDone,
            ),
          ),
        ],
      ),
    );
  }
}