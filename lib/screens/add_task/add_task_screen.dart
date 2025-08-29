import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../models/task_model.dart';
import '../../constants/tap_feedback_helpers.dart';
import '../../constants/theme_color.dart';
import '../custom_dropdown/custom_dropdown.dart';
import '../attachment_viewers/video_player_screen.dart';
import '../attachment_viewers/audio_player_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? existingTask;
  final dynamic taskKey;
  final String? currentUserEmail;

  const AddTaskScreen({
    super.key,
    this.existingTask,
    this.taskKey,
    this.currentUserEmail,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Form controllers and focus nodes
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedDurationController = TextEditingController();
  
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _durationFocusNode = FocusNode();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Task data fields
  String _selectedCategory = 'Work';
  DateTime? _startDate;
  DateTime? _dueDate;
  TimeOfDay? _startTime;
  TimeOfDay? _dueTime;
  int? _estimatedDurationMinutes;
  TaskPriority _priority = TaskPriority.medium;
  String _selectedReminder = 'No reminder';
  TaskRepeatType _repeatType = TaskRepeatType.none;
  Map<String, dynamic>? _repeatConfig;
  DateTime? _repeatEndDate;
  List<String> _attachmentPaths = [];
  
  // UI state
  bool _isLoading = false;
  bool _isEditing = false;
  
  // Categories and options
  List<String> _categories = ['Work', 'Personal', 'Shopping', 'Health'];
  List<String> _customCategories = [];
  List<String> get _allCategories => [..._categories, ..._customCategories];

  final List<String> _reminderOptions = [
    'No reminder',
    '5 minutes before',
    '15 minutes before',
    '30 minutes before',
    '1 hour before',
    '2 hours before',
    '1 day before',
    '2 days before',
    '1 week before',
  ];

  final List<String> _repeatOptions = [
    'No repeat',
    'Daily',
    'Weekly',
    'Monthly',
  ];

  static const int descriptionMaxLength = 200;

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
    _initializeTask();
  }

  // Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    if (_isEditing && widget.existingTask != null) {
      // For editing, compare with original task
      final original = widget.existingTask!;
      return _titleController.text.trim() != original.title ||
             _descriptionController.text.trim() != original.description ||
             _selectedCategory != original.tag ||
             _startDate != original.startDate ||
             _dueDate != original.dueDate ||
             _startTime != original.startTime ||
             _dueTime != original.dueTime ||
             _estimatedDurationMinutes != original.estimatedDurationMinutes ||
             _priority != original.priority ||
             _selectedReminder != (original.reminders.isNotEmpty ? original.reminders.first : 'No reminder') ||
             _repeatType != original.repeatType ||
             _repeatConfig != original.repeatConfig ||
             _repeatEndDate != original.repeatEndDate ||
             _attachmentPaths.length != original.attachmentPaths.length ||
             !listEquals(_attachmentPaths, original.attachmentPaths);
    } else {
      // For new task, check if any field has been filled
      return _titleController.text.trim().isNotEmpty ||
             _descriptionController.text.trim().isNotEmpty ||
             _selectedCategory != 'Work' ||
             _startDate != null ||
             _dueDate != null ||
             _startTime != null ||
             _dueTime != null ||
             _estimatedDurationMinutes != null ||
             _priority != TaskPriority.medium ||
             _selectedReminder != 'No reminder' ||
             _repeatType != TaskRepeatType.none ||
             _repeatConfig != null ||
             _repeatEndDate != null ||
             _attachmentPaths.isNotEmpty;
    }
  }

  Future<bool> _showLeaveConfirmation() async {
    if (!_hasUnsavedChanges()) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF7DF27), width: 1),
        ),
        title: Text(
          'Leave Without Saving?',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF7DF27),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave? Your changes will be lost.',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        actions: [
          TapFeedbackHelpers.feedbackTextButton(
            context: context,
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TapFeedbackHelpers.feedbackTextButton(
            context: context,
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Leave',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Custom snackbar for user feedback
  void _showSnack(String message, {bool isError = false, IconData? icon}) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      final snackBar = SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: isError ? Colors.redAccent : const Color(0xFFF7DF27),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon ??
                    (isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline),
                color: isError ? Colors.redAccent : const Color(0xFFF7DF27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
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
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedDurationController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _durationFocusNode.dispose();
    super.dispose();
  }

  // Load user's custom categories
  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final customList = prefs.getStringList('customCategories_${widget.currentUserEmail}') ?? [];
    setState(() {
      _customCategories = customList;
    });
  }

  // Initialize task data for editing or new task
  void _initializeTask() {
    if (widget.existingTask != null) {
      _isEditing = true;
      final task = widget.existingTask!;
      
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedCategory = task.tag;
      _startDate = task.startDate;
      _dueDate = task.dueDate;
      _startTime = task.startTime;
      _dueTime = task.dueTime;
      _estimatedDurationMinutes = task.estimatedDurationMinutes;
      _priority = task.priority;
      _selectedReminder = task.reminders.isNotEmpty ? task.reminders.first : 'No reminder';
      _repeatType = task.repeatType;
      _repeatConfig = task.repeatConfig;
      _repeatEndDate = task.repeatEndDate;
      _attachmentPaths = List.from(task.attachmentPaths);
      
      if (task.estimatedDurationMinutes != null) {
        _estimatedDurationController.text = task.estimatedDurationMinutes.toString();
      }
    } else {
      _startDate = DateTime.now();
      _dueDate = DateTime.now().add(const Duration(days: 1));
      _startTime = TimeOfDay.now();
      final now = TimeOfDay.now();
      final dueHour = (now.hour + 1) % 24;
      _dueTime = TimeOfDay(hour: dueHour, minute: now.minute);
    }
  }

  // Save task to Hive database
  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnack(
        'Title is required',
        isError: true,
      );
      return;
    }
    
    // Validate date and time logic
    if (_startDate != null && _dueDate != null && _startDate!.isAfter(_dueDate!)) {
      _showSnack(
        'Start date cannot be after due date',
        isError: true,
      );
      return;
    }
    
    if (_startTime != null && _dueTime != null && _startDate == _dueDate) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final dueMinutes = _dueTime!.hour * 60 + _dueTime!.minute;
      if (startMinutes >= dueMinutes) {
        _showSnack(
          'Start time must be before due time on the same day',
          isError: true,
        );
        return;
      }
    }
    
    if (widget.currentUserEmail == null || widget.currentUserEmail!.isEmpty) {
      _showSnack(
        'User email is required for data isolation',
        isError: true,
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final task = TaskModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        time: _dueTime?.format(context) ?? TimeOfDay.now().format(context),
        tag: _selectedCategory,
        userEmail: widget.currentUserEmail!,
        startDate: _startDate,
        dueDate: _dueDate,
        startTime: _startTime,
        dueTime: _dueTime,
        estimatedDurationMinutes: _estimatedDurationMinutes,
        priority: _priority,
        reminders: _selectedReminder != 'No reminder' ? [_selectedReminder] : [],
        repeatType: _repeatType,
        repeatConfig: _repeatConfig,
        repeatEndDate: _repeatEndDate,
        subtasks: [],
        attachmentPaths: _attachmentPaths,

      );

      final boxName = 'tasksBox_${widget.currentUserEmail}';
      Box<TaskModel> taskBox;
      
      if (!Hive.isBoxOpen(boxName)) {
        taskBox = await Hive.openBox<TaskModel>(boxName);
      } else {
        taskBox = Hive.box<TaskModel>(boxName);
      }

      if (_isEditing && widget.taskKey != null) {
        await taskBox.put(widget.taskKey, task);
      } else {
        await taskBox.add(task);
      }

      if (mounted) {
        Navigator.pop(context, task);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          'Error saving task: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Change reminder selection
  void _changeReminder(int direction) {
    final currentIndex = _reminderOptions.indexOf(_selectedReminder);
    final newIndex = (currentIndex + direction) % _reminderOptions.length;
    setState(() {
      _selectedReminder = _reminderOptions[newIndex];
    });
  }

  // Pick file attachments
  Future<void> _pickAttachments() async {
    try {
      FocusScope.of(context).unfocus();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi', 'mov', 'mp3', 'wav', 'aac'],
      );

      if (result != null) {
        List<String> validFiles = [];
        
        for (var file in result.files) {
          if (file.path != null) {
            final fileSize = file.size ?? 0;
            if (fileSize > 50 * 1024 * 1024) {
              _showSnack(
                'File ${file.name} is too large. Maximum size is 50MB.',
                isError: true,
              );
              continue;
            }
            
            final extension = file.extension?.toLowerCase() ?? '';
            if (['mp4', 'avi', 'mov', 'mp3', 'wav', 'aac'].contains(extension)) {
              validFiles.add(file.path!);
            } else {
              validFiles.add(file.path!);
            }
          }
        }
        
        if (validFiles.isNotEmpty) {
          setState(() {
            _attachmentPaths.addAll(validFiles);
          });
        }
      }
    } catch (e) {
      _showSnack(
        'Error picking files: $e',
        isError: true,
      );
    }
  }

  // View attachment based on file type
  void _viewAttachment(String filePath) {
    final fileName = filePath.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: TapFeedbackHelpers.feedbackIconButton(
                context: context,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Color(0xFFF7DF27)),
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
              ),
              title: Text(
                fileName,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF7DF27),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load image',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } else if (['mp4', 'avi', 'mov'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: filePath,
            fileName: fileName,
          ),
        ),
      );
    } else if (['mp3', 'wav', 'aac'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerScreen(
            audioPath: filePath,
            fileName: fileName,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFF7DF27), width: 1),
          ),
          title: Text(
            fileName,
            style: GoogleFonts.poppins(
              color: const Color(0xFFF7DF27),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileIcon(extension),
                color: const Color(0xFFF7DF27),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _getFileTypeDescription(extension),
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TapFeedbackHelpers.feedbackTextButton(
              context: context,
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF7DF27),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Get file icon based on extension
  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file type description
  String _getFileTypeDescription(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image File';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video File (Max 10 minutes)';
      case 'mp3':
      case 'wav':
      case 'aac':
        return 'Audio File (Max 10 minutes)';
      default:
        return 'File';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        return await _showLeaveConfirmation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: TapFeedbackHelpers.feedbackIconButton(
            context: context,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              final shouldLeave = await _showLeaveConfirmation();
              if (shouldLeave && mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xFFF7DF27)),
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
          ),
          title: Text(
            _isEditing ? 'Edit Task' : 'Add New Task',
            style: GoogleFonts.poppins(
              color: const Color(0xFFF7DF27),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFF7DF27),
                  ),
                ),
              )
            else
              TapFeedbackHelpers.feedbackTextButton(
                context: context,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _saveTask();
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFF7DF27),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_isEditing)
              TapFeedbackHelpers.feedbackIconButton(
                context: context,
                onPressed: _showDeleteConfirmation,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.red.withOpacity(0.3),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    label: 'Title',
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),

                  _buildDescriptionField(),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Category'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryYellow,
                        width: 1,
                      ),
                    ),
                    child: CustomDropdown(
                      items: _allCategories,
                      selectedItem: _selectedCategory,
                      onItemSelected: (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Date & Time'),
                  _buildDateRangeDisplay(),
                  const SizedBox(height: 12),
                  _buildTimeRangeDisplay(),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _estimatedDurationController,
                    focusNode: _durationFocusNode,
                    label: 'Estimated Duration (minutes)',
                    keyboardType: TextInputType.number,
                                          onChanged: (value) {
                        setState(() {
                          _estimatedDurationMinutes = int.tryParse(value);
                        });
                      },
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Priority'),
                  _buildPrioritySelector(),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Reminder'),
                  _buildReminderStepper(),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Repeat'),
                  _buildRepeatSelector(),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Attachments'),
                  _buildAttachmentsSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryYellow,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryYellow,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            maxLength: descriptionMaxLength,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${_descriptionController.text.length} / $descriptionMaxLength',
                style: GoogleFonts.poppins(
                  color: _descriptionController.text.length > descriptionMaxLength * 0.9 
                      ? Colors.orange 
                      : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeDisplay() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'Start Date',
            date: _startDate,
            onDateSelected: (date) {
              setState(() {
                _startDate = date;
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, color: AppColors.primaryYellow, size: 20),
        ),
        Expanded(
          child: _buildDatePicker(
            label: 'Due Date',
            date: _dueDate,
            onDateSelected: (date) {
              setState(() {
                _dueDate = date;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeDisplay() {
    return Row(
      children: [
        Expanded(
          child: _buildTimePicker(
            label: 'Start Time',
            time: _startTime,
            onTimeSelected: (time) {
              setState(() {
                _startTime = time;
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, color: AppColors.primaryYellow, size: 20),
        ),
        Expanded(
          child: _buildTimePicker(
            label: 'Due Time',
            time: _dueTime,
            onTimeSelected: (time) {
              setState(() {
                _dueTime = time;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
  }) {
    return TapFeedbackHelpers.tapFeedbackContainer(
      context: context,
      onTap: () async {
        FocusScope.of(context).unfocus();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                dialogBackgroundColor: Colors.black,
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryYellow,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryYellow,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null 
                    ? '${date.day}/${date.month}/${date.year}'
                    : 'Select $label',
                style: TextStyle(
                  color: date != null ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.05),
      foregroundColor: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    return TapFeedbackHelpers.tapFeedbackContainer(
      context: context,
      onTap: () async {
        FocusScope.of(context).unfocus();
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                dialogBackgroundColor: Colors.black,
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryYellow,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryYellow,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                time != null 
                    ? time.format(context)
                    : 'Select $label',
                style: TextStyle(
                  color: time != null ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.05),
      foregroundColor: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildPrioritySelector() {
    return Wrap(
      spacing: 8,
      children: TaskPriority.values.map((priority) {
        final isSelected = _priority == priority;
        final color = _getPriorityColor(priority);
        
        return TapFeedbackHelpers.tapFeedbackContainer(
          context: context,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _priority = priority;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.primaryYellow,
                width: 1,
              ),
            ),
            child: Text(
              priority.name.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          backgroundColor: isSelected ? color : Colors.white.withOpacity(0.05),
          foregroundColor: isSelected ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return AppColors.primaryYellow;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

  Widget _buildReminderStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryYellow,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TapFeedbackHelpers.feedbackIconButton(
            context: context,
            onPressed: () {
              FocusScope.of(context).unfocus();
              _changeReminder(-1);
            },
            icon: const Icon(Icons.chevron_left, color: AppColors.primaryYellow),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
          ),
          Expanded(
            child: Text(
              _selectedReminder,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TapFeedbackHelpers.feedbackIconButton(
            context: context,
            onPressed: () {
              FocusScope.of(context).unfocus();
              _changeReminder(1);
            },
            icon: const Icon(Icons.chevron_right, color: AppColors.primaryYellow),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSelector() {
    return Wrap(
      spacing: 8,
      children: _repeatOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final repeatType = TaskRepeatType.values[index];
        final isSelected = _repeatType == repeatType;
        
        return TapFeedbackHelpers.tapFeedbackContainer(
          context: context,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _repeatType = repeatType;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryYellow : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryYellow,
                width: 1,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          backgroundColor: isSelected ? AppColors.primaryYellow : Colors.white.withOpacity(0.05),
          foregroundColor: isSelected ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        );
      }).toList(),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TapFeedbackHelpers.feedbackButton(
            context: context,
            onPressed: _pickAttachments,
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: Colors.black,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attach_file, color: Colors.black, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Add Attachment',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_attachmentPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._attachmentPaths.map((path) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryYellow,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TapFeedbackHelpers.tapFeedbackContainer(
                    context: context,
                    onTap: () => _viewAttachment(path),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(path.split('.').last.toLowerCase()),
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            path.split('/').last,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFF7DF27).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                TapFeedbackHelpers.feedbackIconButton(
                  context: context,
                  onPressed: () {
                    setState(() {
                      _attachmentPaths.remove(path);
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red.withOpacity(0.3),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF7DF27), width: 1),
        ),
        title: Text(
          'Delete Task',
          style: GoogleFonts.poppins(
            color: const Color(0xFFF7DF27),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        actions: [
          TapFeedbackHelpers.feedbackTextButton(
            context: context,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TapFeedbackHelpers.feedbackTextButton(
            context: context,
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTask();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask() async {
    if (widget.taskKey == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final boxName = 'tasksBox_${widget.currentUserEmail}';
      Box<TaskModel> taskBox;
      
      if (!Hive.isBoxOpen(boxName)) {
        taskBox = await Hive.openBox<TaskModel>(boxName);
      } else {
        taskBox = Hive.box<TaskModel>(boxName);
      }

      await taskBox.delete(widget.taskKey);
      
      if (mounted) {
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          'Error deleting task: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}