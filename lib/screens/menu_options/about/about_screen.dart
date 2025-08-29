import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/theme_color.dart';
import '../privacy_policy/privacy_policy.dart';
import '../rate_us/rate_us_screen.dart';
import '../feedback/feedback_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taskura_app/constants/app_decor.dart';
import '../../../constants/tap_feedback_helpers.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // App version display
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  // Load app version from package info
  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
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
          'About',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100, width: 100),
            const SizedBox(height: 16),

            Text(
              'Taskura',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Version $_appVersion',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: _buildSectionTitle('About the App'),
            ),
            _buildSectionContent(
              'Taskura is your intuitive and powerful task management companion, designed to help you organize your life, boost productivity, and achieve your goals. Create, categorize, and track your tasks with ease, all within a simple and elegant interface.',
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: _buildSectionTitle('Developed By'),
            ),
            _buildSectionContent(
              'Developed with passion by Rabia Aziz, Flutter App Developer, a dedicated Software Engineering student and UI/UX Designer, focused on crafting seamless digital experiences.',
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: _buildSectionTitle('Our Vision'),
            ),
            _buildSectionContent(
              'Taskura is continuously evolving with regular updates and improvements. Recent updates include multi-selection functionality, attachment support, enhanced profile management, and improved UI/UX. We plan to introduce exciting features like cloud synchronization and collaborative task management in future updates, ensuring your data is always safe and accessible.',
            ),
            const SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 24),
              child: _buildSectionTitle('Quick Links'),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: AppDecor.yellowBox,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TapFeedbackHelpers.feedbackTextButton(
                    context: context,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                    child: const Text('Privacy Policy'),
                  ),
                  const SizedBox(height: 8),
                  TapFeedbackHelpers.feedbackTextButton(
                    context: context,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RateUsScreen(),
                          ),
                        ),
                    child: const Text('Rate Us'),
                  ),
                  const SizedBox(height: 8),
                  TapFeedbackHelpers.feedbackTextButton(
                    context: context,
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackScreen(),
                          ),
                        ),
                    child: const Text('Send Feedback'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.center,
              child: Text(
                '© 2025 Rabia Aziz. All rights reserved.',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
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
}
