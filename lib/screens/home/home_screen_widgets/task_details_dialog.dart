import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../models/task_model.dart';
import '../../../constants/tap_feedback_helpers.dart';
import '../../add_task/add_task_screen.dart';
import '../../attachment_viewers/video_player_screen.dart';
import '../../attachment_viewers/audio_player_screen.dart';

class TaskDetailsDialog extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? currentUserEmail;

  const TaskDetailsDialog({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    this.currentUserEmail,
  });

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final Set<String> _expandedDescriptions = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF7DF27),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'Title',
                      widget.task.title,
                      icon: Icons.title,
                    ),
                    
                    if (widget.task.description.isNotEmpty)
                      _buildExpandableDescriptionSection(widget.task),
                    
                    _buildDetailSection(
                      'Category',
                      widget.task.tag,
                      icon: Icons.category,
                      valueColor: const Color(0xFFF7DF27),
                    ),
                    
                    if (widget.task.priority != TaskPriority.medium)
                      _buildDetailSection(
                        'Priority',
                        widget.task.priority.name.toUpperCase(),
                        icon: Icons.priority_high,
                        valueColor: _getPriorityColor(widget.task.priority),
                      ),
                    
                    if (widget.task.hasDateRange)
                      _buildDetailSection(
                        'Date Range',
                        '${_formatDate(widget.task.startDate!)} → ${_formatDate(widget.task.dueDate!)}',
                        icon: Icons.calendar_today,
                      ),
                    
                    if (widget.task.hasTimeRange)
                      _buildDetailSection(
                        'Time Range',
                        '${widget.task.startTime?.format(context)} → ${widget.task.dueTime?.format(context)}',
                        icon: Icons.access_time,
                      ),
                    
                    if (!widget.task.hasTimeRange && widget.task.time.isNotEmpty)
                      _buildDetailSection(
                        'Time',
                        widget.task.time,
                        icon: Icons.access_time,
                      ),
                    
                    if (widget.task.estimatedDurationMinutes != null)
                      _buildDetailSection(
                        'Estimated Duration',
                        '${widget.task.estimatedDurationMinutes} minutes',
                        icon: Icons.timer,
                      ),
                    
                    if (widget.task.reminders.isNotEmpty)
                      _buildDetailSection(
                        'Reminders',
                        widget.task.reminders.join(', '),
                        icon: Icons.notifications,
                      ),
                    
                    if (widget.task.isRecurring)
                      _buildDetailSection(
                        'Repeat',
                        _getRepeatDisplayText(widget.task),
                        icon: Icons.repeat,
                      ),
                    
                    if (widget.task.attachmentPaths.isNotEmpty)
                      _buildAttachmentsSection(widget.task),
                    
                    _buildDetailSection(
                      'Status',
                      widget.task.isDone ? 'Completed' : 'Pending',
                      icon: Icons.check_circle,
                      valueColor: widget.task.isDone ? Colors.green : Colors.orange,
                    ),
                    
                    if (widget.task.createdAt != null)
                      _buildDetailSection(
                        'Created',
                        _formatDateTime(widget.task.createdAt!),
                        icon: Icons.create,
                        valueColor: Colors.white70,
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                                 TapFeedbackHelpers.feedbackTextButton(
                   context: context,
                   onPressed: () {
                     FocusScope.of(context).unfocus();
                     Navigator.pop(context);
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => AddTaskScreen(
                           existingTask: widget.task,
                           taskKey: widget.task.key,
                           currentUserEmail: widget.currentUserEmail,
                         ),
                       ),
                     );
                   },
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF7DF27),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TapFeedbackHelpers.feedbackTextButton(
                  context: context,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: const Color(0xFFF7DF27),
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.attach_file,
            color: Color(0xFFF7DF27),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attachments (${task.attachmentPaths.length})',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ...task.attachmentPaths.map((path) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TapFeedbackHelpers.tapFeedbackContainer(
                    context: context,
                    onTap: () => _viewAttachment(path),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(path.split('.').last.toLowerCase()),
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            path.split('/').last,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFF7DF27).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDescriptionSection(TaskModel task) {
    return StatefulBuilder(
      builder: (context, setState) {
        final String taskKey = task.key.toString();
        final bool isExpanded = _expandedDescriptions.contains(taskKey);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.description,
                color: Color(0xFFF7DF27),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textSpan = TextSpan(
                          text: task.description,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                        
                        final textPainter = TextPainter(
                          text: textSpan,
                          textDirection: TextDirection.ltr,
                          maxLines: isExpanded ? null : 3,
                        );
                        
                        textPainter.layout(maxWidth: constraints.maxWidth);
                        
                        final isTextOverflowing = textPainter.didExceedMaxLines;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.description,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              maxLines: isExpanded ? null : 3,
                              overflow: isExpanded ? null : TextOverflow.ellipsis,
                            ),
                            if (isTextOverflowing)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: TapFeedbackHelpers.feedbackTextButton(
                                  context: context,
                                  onPressed: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedDescriptions.remove(taskKey);
                                      } else {
                                        _expandedDescriptions.add(taskKey);
                                      }
                                    });
                                  },
                                  child: Text(
                                    isExpanded ? 'Show less' : 'Show more',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFF7DF27),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return const Color(0xFFF7DF27);
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }

  String _getRepeatDisplayText(TaskModel task) {
    switch (task.repeatType) {
      case TaskRepeatType.daily:
        return 'Daily';
      case TaskRepeatType.weekly:
        return 'Weekly';
      case TaskRepeatType.monthly:
        return 'Monthly';
      case TaskRepeatType.none:
      default:
        return 'No repeat';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

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
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

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
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  String _getFileTypeDescription(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image file';
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'Video file';
      case 'mp3':
      case 'wav':
      case 'aac':
        return 'Audio file';
      case 'pdf':
        return 'PDF document';
      case 'doc':
      case 'docx':
        return 'Word document';
      default:
        return 'File attachment';
    }
  }
}
