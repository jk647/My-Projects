import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/tap_feedback_helpers.dart';
import 'home_screen_helpers.dart';

class SelectionActionBar extends StatelessWidget {
  final int selectedCount;
  final bool areSelectedTasksPinned;
  final VoidCallback onPinPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onCancelPressed;

  const SelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.areSelectedTasksPinned,
    required this.onPinPressed,
    required this.onDeletePressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: kToolbarHeight + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HomeScreenHelpers.primaryYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$selectedCount',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                TapFeedbackHelpers.feedbackIconButton(
                  context: context,
                  onPressed: onPinPressed,
                  icon: Icon(
                    areSelectedTasksPinned ? Icons.push_pin_outlined : Icons.push_pin,
                    color: HomeScreenHelpers.primaryYellow,
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: HomeScreenHelpers.primaryYellow.withOpacity(0.3),
                ),
                const SizedBox(width: 16),
                
                TapFeedbackHelpers.feedbackIconButton(
                  context: context,
                  onPressed: onDeletePressed,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red.withOpacity(0.3),
                ),
                const Spacer(),
                
                TapFeedbackHelpers.feedbackTextButton(
                  context: context,
                  onPressed: onCancelPressed,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
