import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/theme_color.dart';
import '../../../constants/tap_feedback_helpers.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _showStyledSnackBar(
    BuildContext context,
    String msg, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? const Color(0xFF000000) : const Color(0xFF000000),
            border: Border.all(
              color: isError ? Colors.redAccent : AppColors.primaryYellow,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.redAccent : AppColors.primaryYellow,
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

  Future<void> _launchEmail(
    BuildContext context,
    String emailAddress,
    String subject,
  ) async {
    final String encodedSubject = Uri.encodeComponent(subject);
    final Uri emailLaunchUri = Uri.parse(
      'mailto:$emailAddress?subject=$encodedSubject',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      _showStyledSnackBar(
        context,
        "Could not open email app. Please ensure you have a mail app configured.",
        isError: true,
      );
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
          'Privacy Policy',
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
              'Privacy Policy for Taskura',
              style: GoogleFonts.poppins(
                color: AppColors.primaryYellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: August 28, 2025',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
              'This Privacy Policy describes how Taskura App, developed by Rabia Aziz, collects, uses, and protects your information when you use our mobile application. We are committed to protecting your privacy and ensuring you have a safe and secure experience with our App.',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('2. Information We Collect'),
            _buildSectionContent(
              'Taskura is designed to be an offline application, meaning most of your data is stored directly on your device. We collect the following types of information:',
            ),
            _buildListItem(
              '• Personal Identifiable Information (PII): We collect your name (as provided during signup or edited in your profile) and your email address for account management within the App. Your profile picture, if you choose to set one, is stored as a file path on your device, and the image file itself remains on your local storage.',
            ),
            _buildListItem(
              '• User-Generated Content: This includes tasks you create (title, description, category tag, time, completion status, pinned status, priority level, repeat settings, and attachments), custom categories you define, and any feedback you submit through the App. This content is stored locally on your device.',
            ),
            _buildListItem(
              '• Non-Personal Information: The App does not intentionally collect or transmit any non-personal device information (e.g., device model, operating system version, detailed app usage statistics) to external servers.',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('3. How We Use Your Information'),
            _buildSectionContent(
              'The information we collect is used primarily to provide and improve the Taskura App experience for you:',
            ),
            _buildListItem(
              '• To manage your tasks and categories within the App.',
            ),
            _buildListItem(
              '• To personalize your App experience (e.g., displaying your name and profile picture).',
            ),
            _buildListItem(
              '• To allow you to retrieve your password (via the Forgot Password feature).',
            ),
            _buildListItem(
              '• To receive and respond to your feedback (via your device\'s email client).',
            ),
            _buildListItem(
              '• For internal analytics to understand App usage patterns (this data remains on your device and is not transmitted externally).',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('4. Data Storage and Retention'),
            _buildSectionContent(
              'All your personal data and user-generated content (including your name, email, profile picture path, tasks, custom categories, and task attachments) are stored locally on your device using `SharedPreferences` and `Hive`. This means your data does not reside on our servers and is not directly accessible by us.',
            ),
            _buildSectionContent(
              'Your data will remain on your device until you uninstall the App, manually clear the App\'s data through your device settings, or delete specific content within the App (e.g., individual tasks or categories).',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('5. Data Sharing and Disclosure'),
            _buildSectionContent(
              'Taskura does not share, sell, rent, or trade your personal information with third parties. As an offline application, your data is not transmitted to external servers by the App itself.',
            ),
            _buildListItem(
              '• Feedback via Email: When you submit feedback, the App launches your device\'s default email client with pre-filled information (your name, email, feedback text, and timestamp) to be sent to our support email address. This process requires your explicit action to send the email from your device.',
            ),
            _buildListItem(
              '• Legal Requirements: We may disclose your information if required to do so by law or in response to valid requests by public authorities (e.g., a court order or government agency).',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('6. Children\'s Privacy'),
            _buildSectionContent(
              'Taskura is a general audience application and is not specifically directed at children under the age of 13. We do not knowingly collect personal identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal data, please contact us: ',
            ),
            TapFeedbackHelpers.tapFeedbackContainer(
              context: context,
              onTap:
                  () => _launchEmail(
                    context,
                    'swe.rabiaaziz@gmail.com',
                    'Privacy Policy Inquiry - Children\'s Data',
                  ),
              child: Text(
                'swe.rabiaaziz@gmail.com',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryYellow,
                  fontSize: 14,
                  height: 1.5,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryYellow,
                  decorationThickness: 1.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('7. Changes to This Privacy Policy'),
            _buildSectionContent(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
            ),
            _buildSectionContent(
              'Future Development: We plan to enhance Taskura with online features, such as cloud synchronization for data backup and multi-user collaboration. Recent updates have already introduced advanced features like multi-selection, attachment support, and enhanced profile management. Should additional online features be implemented, this Privacy Policy will be updated to reflect any changes in data collection, storage, and sharing practices.',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('8. Contact Us'),
            _buildSectionContent(
              'If you have any questions or suggestions about our Privacy Policy, please do not hesitate to contact us at:',
            ),
            TapFeedbackHelpers.tapFeedbackContainer(
              context: context,
              onTap:
                  () => _launchEmail(
                    context,
                    'swe.rabiaaziz@gmail.com',
                    'Privacy Policy Inquiry - General',
                  ),
                            child: Text(
                'swe.rabiaaziz@gmail.com',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryYellow,
                  fontSize: 14,
                  height: 1.5,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryYellow,
                  decorationThickness: 1.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
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

  Widget _buildListItem(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
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
}
