import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/tap_feedback_helpers.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF7DF27)),
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
        ),
        centerTitle: true,
        title: Text(
          'Terms of Service',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF7DF27),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: August 28, 2025',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              '1. Acceptance of Terms',
              'By downloading, installing, or using the Taskura app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.',
            ),
            
            _buildSection(
              '2. Description of Service',
              'Taskura is a task management application that allows users to create, organize, and track their tasks. The app provides features including task creation, categorization, reminders, attachments, and profile management.',
            ),
            
            _buildSection(
              '3. User Accounts',
              'You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You must provide accurate and complete information when creating your account.',
            ),
            
            _buildSection(
              '4. Acceptable Use',
              'You agree to use the app only for lawful purposes and in accordance with these Terms. You may not use the app to store, transmit, or share any content that is illegal, harmful, threatening, abusive, or violates the rights of others.',
            ),
            
            _buildSection(
              '5. Privacy and Data',
              'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the app, to understand our practices regarding the collection and use of your information.',
            ),
            
            _buildSection(
              '6. Intellectual Property',
              'The Taskura app and its original content, features, and functionality are owned by Rabia Aziz and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
            ),
            
            _buildSection(
              '7. User Content',
              'You retain ownership of any content you create or upload to the app. By using the app, you grant us a limited license to store and process your content to provide the service.',
            ),
            
            _buildSection(
              '8. Termination',
              'We may terminate or suspend your account and access to the app immediately, without prior notice, for any reason, including if you breach these Terms of Service.',
            ),
            
            _buildSection(
              '9. Disclaimer of Warranties',
              'The app is provided "as is" without warranties of any kind. We do not guarantee that the app will be error-free or uninterrupted.',
            ),
            
            _buildSection(
              '10. Limitation of Liability',
              'In no event shall Taskura or its developers be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or relating to your use of the app.',
            ),
            
            _buildSection(
              '11. Changes to Terms',
              'We reserve the right to modify these Terms of Service at any time. We will notify users of any material changes by updating the "Last updated" date.',
            ),
            
            _buildSection(
              '12. Contact Information',
              'If you have any questions about these Terms of Service, please contact us through the feedback section in the app.',
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2025 Rabia Aziz. All rights reserved.',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFFF7DF27),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
