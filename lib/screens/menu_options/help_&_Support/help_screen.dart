import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskura_app/constants/app_decor.dart';
import '../../../constants/theme_color.dart';
import '../feedback/feedback_screen.dart';
import '../../../constants/tap_feedback_helpers.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          'Help & Support',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Find answers to common questions and learn how to use Taskura effectively.',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('(FAQs)'),
            const SizedBox(height: 16),
            
            // Task management FAQs
            _buildFaqItem(
              context,
              question: 'How do I add a new task?',
              answer:
                  'To add a new task, tap the "+" button at the bottom of the home screen. Fill in the details like title, description, and choose a category. You can also set a time for reminders, priority level, and add attachments to your tasks.',
            ),
            _buildFaqItem(
              context,
              question: 'How can I create custom categories?',
              answer:
                  'To add a custom category, swipe right through the default categories on the home screen. At the end, tap the "+ Add" button. Then, enter a name for your custom category and tap Add to save it.',
            ),
            _buildFaqItem(
              context,
              question: 'How do I view a task\'s details?',
              answer:
                  'Simply tap once on any task to view its complete details including title, description, time, category, priority, and any attachments. The task details will be displayed in a comprehensive dialog.',
            ),
            
            // Task operations FAQs
            _buildFaqItem(
              context,
              question: 'How do I pin and unpin tasks?',
              answer:
                  'To pin a task, long-press on the task to enter selection mode. A Grey action bar will appear at the top with pin and delete options. Tap the pin icon to pin selected tasks. You can select multiple tasks at once for bulk pinning.',
            ),

            _buildFaqItem(
              context,
              question: 'How do I edit or delete tasks?',
              answer:
                  'To edit a task, tap on it to open the task details dialog, then tap the "Edit" button. To delete tasks, long-press to enter selection mode, select the tasks you want to delete, then tap the delete icon in the action bar. You can also swipe right on individual tasks to delete them.',
            ),
            
            // Attachment and media FAQs
            _buildFaqItem(
              context,
              question: 'How do I add attachments to tasks?',
              answer:
                  'When creating or editing a task, tap the "Add Attachment" button. You can select images, videos, audio files from your device. To view attachments, tap on the task to open details, then tap on any attachment. Images will open in full screen, videos will play with controls, and audio files will open in a player with play/pause and seek controls.',
            ),
                        
            _buildFaqItem(
              context,
              question: 'Is my data stored online?',
              answer:
                  'No, Taskura is an offline app. All your tasks, categories, profile data, and attachments are stored securely on your device\'s local storage (using SharedPreferences and Hive). Your data is not transmitted to any external servers.',
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('How-to Guides'),
            const SizedBox(height: 16),
            _buildSectionContent(
              '• Set Profile: On the home screen, tap your profile icon in the top right corner. Then, tap the Edit button below the circular avatar.\nTo use an existing photo, select "Choose from Gallery".\nTo take a new photo, select "Take a Photo."\nYou can crop and rotate your photo before saving.',
            ),
            _buildSectionContent(
              '• Multi-Selection: Long-press on any task to enter selection mode. Select multiple tasks and use the action bar to pin or delete them in bulk.',
            ),
            _buildSectionContent(
              '• Clearing All Tasks: In the "Settings", you will find an option to "Clear All Tasks". Be careful, as this action is permanent and will delete all your saved tasks.',
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('Troubleshooting'),
            const SizedBox(height: 16),
            _buildSectionContent(
              '• App not responding/Crashing: Try closing the app completely and reopening it. If the issue persists, try restarting your device.',
            ),
            _buildSectionContent(
              '• Data not updating: Ensure your app is updated to the latest version. Sometimes, simply navigating away from the screen and coming back can refresh the data.',
            ),
            const SizedBox(height: 30),

            _buildSectionTitle('Contact Support'),
            const SizedBox(height: 16),
            _buildSectionContent(
              'If you still have questions or need further assistance, please feel free to send us your feedback. We are here to help!',
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Material(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.black.withOpacity(0.3),
                    highlightColor: Colors.black.withOpacity(0.1),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Send Us Feedback',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.primaryYellow,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: AppDecor.yellowBox,
      child: ExpansionTile(
        iconColor: AppColors.primaryYellow,
        collapsedIconColor: AppColors.primaryYellow,
        title: Text(
          question,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
