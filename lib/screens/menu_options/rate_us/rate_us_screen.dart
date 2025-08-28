import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskura_app/constants/theme_color.dart';
import 'package:taskura_app/constants/tap_feedback_helpers.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  int _currentRating = 0;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndRating();
  }

  Future<void> _loadCurrentUserAndRating() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('currentUserEmail');

    if (_currentUserEmail != null) {
      final ratingKey = 'appRating_$_currentUserEmail';
      setState(() {
        _currentRating = prefs.getInt(ratingKey) ?? 0;
      });
    } else {}
  }

  Future<void> _saveRating(int rating) async {
    if (_currentUserEmail == null) {
      _showStyledSnackBar("Please log in to rate the app.", isError: true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final ratingKey = 'appRating_$_currentUserEmail';

    if (rating == _currentRating) {
      await prefs.setInt(ratingKey, 0);
      setState(() {
        _currentRating = 0;
      });
      _showStyledSnackBar("Rating removed.");
    } else {
      await prefs.setInt(ratingKey, rating);
      setState(() {
        _currentRating = rating;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final bool hasRated = _currentRating > 0;

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
          'Rate Us',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hasRated ? "You have rated us!" : "Enjoying Taskura?",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                hasRated
                    ? "Your current rating: $_currentRating out of 5 stars."
                    : "Please select stars to rate us.",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return TapFeedbackHelpers.tapFeedbackContainer(
                    context: context,
                    onTap: () {
                      _saveRating(index + 1);
                    },
                    child: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF7DF27),
                      size: 48,
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
                  );
                }),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Material(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      if (_currentRating > 0) {
                        _showStyledSnackBar(
                          "Thank you for your rating of $_currentRating stars!",
                        );
                      } else {
                        _showStyledSnackBar(
                          "Please select a rating before submitting.",
                          isError: true,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.black.withOpacity(0.3),
                    highlightColor: Colors.black.withOpacity(0.1),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Submit Rating',
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
      ),
    );
  }
}
