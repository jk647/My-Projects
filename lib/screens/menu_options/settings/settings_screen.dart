import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskura_app/constants/theme_color.dart';
import 'package:taskura_app/constants/app_decor.dart';
import 'package:taskura_app/constants/tap_feedback_helpers.dart';

import '../../../models/task_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  List<String> _customCategories = [];
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('currentUserEmail');
    _customCategories =
        prefs.getStringList('customCategories_$_currentUserEmail') ?? [];
    setState(() {});
  }

  void _showStyledSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            border: Border.all(color: AppColors.primaryYellow, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryYellow,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearAllTasks() async {
    final boxName = 'tasksBox_${_currentUserEmail ?? 'default'}';
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<TaskModel>(boxName);
      if (box.isEmpty) return;

      final shouldClear = await showDialog<bool>(
        context: context,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: AppDecor.blackBox,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Are you sure?",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "This will delete all your tasks permanently.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TapFeedbackHelpers.feedbackTextButton(
                          context: context,
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: AppColors.primaryYellow),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TapFeedbackHelpers.feedbackTextButton(
                          context: context,
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );

      if (shouldClear == true) {
        await box.clear();
        _showStyledSnackBar("All tasks cleared.");
      }
    }
  }

  Future<void> _deleteCustomCategory(String category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: AppDecor.yellowBox,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Delete Category and Tasks?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete the category '$category' and all its associated tasks permanently?",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TapFeedbackHelpers.feedbackTextButton(
                        context: context,
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: AppColors.primaryYellow),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TapFeedbackHelpers.feedbackTextButton(
                        context: context,
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    if (shouldDelete == true) {
      final prefs = await SharedPreferences.getInstance();
      final boxName = 'tasksBox_${_currentUserEmail ?? 'default'}';
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<TaskModel>(boxName);
      }
      final taskBox = Hive.box<TaskModel>(boxName);

      final tasksToDelete =
          taskBox.values
              .where(
                (task) =>
                    task.tag == category && task.userEmail == _currentUserEmail,
              )
              .toList();
      for (var task in tasksToDelete) {
        await task.delete();
      }

      _customCategories.remove(category);
      await prefs.setStringList(
        'customCategories_$_currentUserEmail',
        _customCategories,
      );
      await prefs.setBool('categoriesChanged', true);

      setState(() {});
      _showStyledSnackBar("Successfully deleted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TapFeedbackHelpers.feedbackIconButton(
          context: context,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryYellow),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
        ),
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.white),
            ),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            activeColor: const Color(0xFFF7DF27),
          ),
          const SizedBox(height: 10),
          TapFeedbackHelpers.feedbackListTile(
            context: context,
            title: const Text(
              'Clear All Tasks',
              style: TextStyle(color: Colors.white),
            ),
            leading: const Icon(Icons.delete, color: Color(0xFFF7DF27)),
            onTap: _clearAllTasks,
            backgroundColor: Colors.black,
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            title: const Text(
              'Delete Custom Categories',
              style: TextStyle(color: Colors.white),
            ),
            children:
                _customCategories.isEmpty
                    ? [
                      const ListTile(
                        title: Text(
                          "No custom categories",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ]
                    : _customCategories.map((category) {
                      return ListTile(
                        title: Text(
                          category,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: TapFeedbackHelpers.feedbackIconButton(
                          context: context,
                          onPressed: () => _deleteCustomCategory(category),
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.primaryYellow,
                          ),
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "App Version 0.1.0",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
