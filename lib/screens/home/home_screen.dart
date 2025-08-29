import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:taskura_app/main.dart';
import '../../models/task_model.dart';
import '../profile/profile_screen.dart';
import '../add_task/add_task_screen.dart';
import '../../constants/tap_feedback_helpers.dart';
import 'home_screen_widgets/home_app_bar.dart';
import 'home_screen_widgets/app_drawer.dart';
import 'home_screen_widgets/home_content.dart';
import 'home_screen_widgets/selection_action_bar.dart';
import 'home_screen_widgets/task_details_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  // Data management
  List<String> _customCategories = [];
  List<String> get _allCategories => [..._categories, ..._customCategories];

  // UI state
  String _searchQuery = '';
  int _selectedCategory = 0;
  File? _profileImage;
  String? _currentUserEmail;
  bool _isBoxReady = false;

  // Multi-selection state
  bool _isSelectionMode = false;
  Set<int> _selectedTasks = {};

  // Default categories
  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Shopping',
    'Health',
  ];

  Box<TaskModel>? taskBox;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileImage();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _loadCustomCategories();
    _loadUserSpecificBox();
  }

  FocusNode _searchFocusNode = FocusNode();
  
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Focus management for navigation
  @override
  void didPushNext() {
    FocusScope.of(context).unfocus();
  }

  @override
  void didPopNext() {
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
  }

  // Load user's custom categories
  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final customList =
        prefs.getStringList('customCategories_$_currentUserEmail') ?? [];
    setState(() {
      _customCategories = customList;
      final maxIndex = _allCategories.length - 1;
      _selectedCategory =
          (_selectedCategory > maxIndex)
              ? (maxIndex >= 0 ? maxIndex : 0)
              : _selectedCategory;
    });
  }

  // Initialize user data and profile
  Future<void> _initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUserEmail');
    setState(() {
      _currentUserEmail = email;
    });

    final imagePath = prefs.getString('profileImagePath_${_currentUserEmail}');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }

    await _loadUserSpecificBox();
  }

  // Load user-specific Hive box
  Future<void> _loadUserSpecificBox() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUserEmail');
    final boxName = 'tasksBox_${email ?? 'default'}';

    if (!Hive.isBoxOpen(boxName)) {
      taskBox = await Hive.openBox<TaskModel>(boxName);
    } else {
      taskBox = Hive.box<TaskModel>(boxName);
    }

    setState(() {
      _isBoxReady = true;
    });
  }

  // Load profile image from storage
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImagePath_$_currentUserEmail');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    } else {
      setState(() {
        _profileImage = null;
      });
    }
  }

  // Add new category dialog
  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF7DF27), width: 1.2),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 34, 32, 19),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF7DF27),
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter category name',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                  TapFeedbackHelpers.feedbackTextButton(
                    context: context,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  const SizedBox(width: 12),
                  TapFeedbackHelpers.feedbackTextButton(
                    context: context,
                        onPressed: () async {
                          final newCategory = controller.text.trim();
                          if (newCategory.isNotEmpty &&
                              !_customCategories.contains(newCategory)) {
                        setState(() {
                          _customCategories.add(newCategory);
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList(
                          'customCategories_$_currentUserEmail',
                          _customCategories,
                        );
                          }
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Color(0xFFF7DF27)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Show task details dialog
  void _showTaskDescriptionDialog(TaskModel task) {
    FocusScope.of(context).unfocus();
    _searchFocusNode.unfocus();
    
    showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(
        task: task,
        currentUserEmail: _currentUserEmail,
        onEdit: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(existingTask: task),
            ),
          );
        },
        onDelete: () async {
          Navigator.of(context).pop();
          await task.delete();
          setState(() {});
        },
      ),
    ).then((_) {
      FocusScope.of(context).unfocus();
      _searchFocusNode.unfocus();
    });
  }

  // Get filtered and sorted tasks
  List<TaskModel> _getVisibleTasks() {
    if (taskBox == null) return [];
    
    final userTasks = taskBox!.values
                .where((task) => task.userEmail == _currentUserEmail)
                .toList();

        final selectedCategory = _allCategories[_selectedCategory];

    final visibleTasks = userTasks.where((task) {
              final matchesCategory =
                  selectedCategory == 'All' || task.tag == selectedCategory;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  task.title.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

        // Sort by pinned status
        visibleTasks.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return 0;
        });

    return visibleTasks;
  }

  // Check if selected tasks are pinned
  bool _areSelectedTasksPinned() {
    final visibleTasks = _getVisibleTasks();
    return _selectedTasks.every((index) => 
        index < visibleTasks.length && visibleTasks[index].isPinned);
  }

  // Pin/unpin selected tasks
  void _pinSelectedTasks() async {
    final visibleTasks = _getVisibleTasks();
    final arePinned = _areSelectedTasksPinned();
    
    for (final index in _selectedTasks) {
      if (index < visibleTasks.length) {
        final task = visibleTasks[index];
        task.isPinned = !arePinned;
        await task.save();
      }
    }
    
    setState(() {
      _isSelectionMode = false;
      _selectedTasks.clear();
    });
    
  }

  // Delete selected tasks
  void _deleteSelectedTasks() async {
    final visibleTasks = _getVisibleTasks();
    
    for (final index in _selectedTasks) {
      if (index < visibleTasks.length) {
        await visibleTasks[index].delete();
      }
    }
    
    setState(() {
      _isSelectionMode = false;
      _selectedTasks.clear();
    });
    
  }

  // Show feedback snackbar
  void _showSnack(String message, {bool isError = false, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
                  children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
                          child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFFF7DF27),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxReady || taskBox == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF7DF27)),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: taskBox!.listenable(),
      builder: (context, Box<TaskModel> box, _) {
        final userTasks = box.values
            .where((task) => task.userEmail == _currentUserEmail)
            .toList();

        final visibleTasks = _getVisibleTasks();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusScope.of(context).unfocus();
             _searchFocusNode.unfocus();
           },
                     child: Scaffold(
             backgroundColor: Colors.black,
             onDrawerChanged: (isOpened) {
               if (!isOpened) {
                        FocusScope.of(context).unfocus();
                 _searchFocusNode.unfocus();
               }
             },
             appBar: _isSelectionMode ? null : HomeAppBar(
              searchQuery: _searchQuery,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
                             onProfileTap: () {
                        FocusScope.of(context).unfocus();
                 _searchFocusNode.unfocus();
                        Navigator.push(
                          context,
                   MaterialPageRoute(builder: (context) => const ProfileScreen()),
                 );
               },
              onProfileImageReload: _loadProfileImage,
              profileImage: _profileImage,
              searchFocusNode: _searchFocusNode,
            ),
                         drawer: AppDrawer(
               onCategoriesChanged: _loadCustomCategories,
             ),
            body: Stack(
              children: [
                HomeContent(
                  userTasks: userTasks,
                  visibleTasks: visibleTasks,
                  allCategories: _allCategories,
                  selectedCategory: _selectedCategory,
                  isSelectionMode: _isSelectionMode,
                  selectedTasks: _selectedTasks,
                                     onCategorySelected: (index) {
                        FocusScope.of(context).unfocus();
                     _searchFocusNode.unfocus();
                     setState(() => _selectedCategory = index);
                   },
                                     onAddCategory: () {
                        FocusScope.of(context).unfocus();
                     _searchFocusNode.unfocus();
                     _showAddCategoryDialog();
                   },
                                     onTaskTap: (task) {
                     FocusScope.of(context).unfocus();
                     _searchFocusNode.unfocus();
                    
                    if (_isSelectionMode) {
                      final taskIndex = visibleTasks.indexOf(task);
                      setState(() {
                        if (_selectedTasks.contains(taskIndex)) {
                          _selectedTasks.remove(taskIndex);
                        } else {
                          _selectedTasks.add(taskIndex);
                        }
                        if (_selectedTasks.isEmpty) {
                          _isSelectionMode = false;
                        }
                      });
                    } else {
                      _showTaskDescriptionDialog(task);
                    }
                  },
                                     onTaskLongPress: (task) {
                     FocusScope.of(context).unfocus();
                     _searchFocusNode.unfocus();
                    
                    if (!_isSelectionMode) {
                      final taskIndex = visibleTasks.indexOf(task);
                      setState(() {
                        _isSelectionMode = true;
                        _selectedTasks.add(taskIndex);
                      });
                    }
                  },
                  onTaskDelete: (task) async {
                                    await task.delete();
                                    setState(() {});
                                  },
                  onTaskToggleDone: (task) async {
                                                task.isDone = !task.isDone;
                                                await task.save();
                                                setState(() {});
                                              },
                ),
                
                // Multi-selection action bar
                if (_isSelectionMode)
                  SelectionActionBar(
                    selectedCount: _selectedTasks.length,
                    areSelectedTasksPinned: _areSelectedTasksPinned(),
                    onPinPressed: _pinSelectedTasks,
                    onDeletePressed: _deleteSelectedTasks,
                    onCancelPressed: () {
                      setState(() {
                        _isSelectionMode = false;
                        _selectedTasks.clear();
                      });
                    },
                                                    ),
                                                  ],
                                                ),
            floatingActionButton: TapFeedbackHelpers.wrapButtonWithFeedback(
              context: context,
                             onPressed: () {
                 FocusScope.of(context).unfocus();
                 _searchFocusNode.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(
                      currentUserEmail: _currentUserEmail,
                    ),
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
              button: FloatingActionButton(
                onPressed: null,
              backgroundColor: const Color(0xFFF7DF27),
              child: const Icon(Icons.add, color: Colors.black),
            ),
              backgroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
              foregroundColor: Colors.black.withOpacity(0.3),
          ),
          ),
        );
      },
    );
  }
}
