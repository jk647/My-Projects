import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:taskura_app/constants/theme_color.dart';
import 'package:taskura_app/constants/app_decor.dart';
import 'package:taskura_app/constants/tap_feedback_helpers.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  String? _currentUserEmail;
  String? _currentUserName;
  bool _isSubmitting = false;

  final String _receiverEmail = 'swe.rabiaaziz@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndName();
  }

  Future<void> _loadCurrentUserAndName() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('currentUserEmail');

    if (_currentUserEmail != null) {
      _currentUserName = prefs.getString('userName_$_currentUserEmail');
      _currentUserName ??= _currentUserEmail;
    }
    setState(() {});
  }

  void _showStyledSnackBar(String msg, {bool isError = false}) {
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

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();

    if (_currentUserEmail == null) {
      _showStyledSnackBar("Please log in to submit feedback.", isError: true);
      return;
    }

    if (feedbackText.isEmpty) {
      _showStyledSnackBar("Feedback cannot be empty.", isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackKey = 'userFeedback_$_currentUserEmail';
      List<String> existingFeedbackJsons =
          prefs.getStringList(feedbackKey) ?? [];
      Map<String, dynamic> newFeedbackEntry = {
        'email': _currentUserEmail,
        'feedback': feedbackText,
        'timestamp': DateTime.now().toIso8601String(),
      };
      existingFeedbackJsons.add(jsonEncode(newFeedbackEntry));
      await prefs.setStringList(feedbackKey, existingFeedbackJsons);
      final String emailSubject = Uri.encodeComponent(
        'Taskura App Feedback from ${_currentUserName ?? _currentUserEmail}',
      );
      final String emailBody = Uri.encodeComponent(
        'User Name: ${_currentUserName ?? 'N/A'}\n'
        'User Email: $_currentUserEmail\n\n'
        'Feedback:\n$feedbackText\n\n'
        'Timestamp: ${DateTime.now().toLocal()}',
      );
      final Uri emailLaunchUri = Uri.parse(
        'mailto:$_receiverEmail?subject=$emailSubject&body=$emailBody',
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
        _feedbackController.clear();
        _showStyledSnackBar(
          "Please send the email from your mail app. Thank you!",
        );
      } else {
        _showStyledSnackBar(
          "Could not open email app. Please ensure you have a mail app configured.",
          isError: true,
        );
      }
    } catch (e) {
      _showStyledSnackBar(
        "Failed to submit feedback. Please try again.",
        isError: true,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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
          'Feedback',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Share your thoughts with us!",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Your feedback helps us improve. Please let us know what you think.",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: AppDecor.yellowBox,
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _feedbackController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Type your feedback here...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isSubmitting
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(color: Colors.grey),
                    )
                  : Material(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _submitFeedback,
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.black.withOpacity(0.3),
                        highlightColor: Colors.black.withOpacity(0.1),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Submit Feedback',
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
          ],
        ),
      ),
    );
  }
}
