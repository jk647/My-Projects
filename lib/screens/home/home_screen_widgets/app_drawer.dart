import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/tap_feedback_helpers.dart';
import '../../menu_options/settings/settings_screen.dart';
import '../../menu_options/rate_us/rate_us_screen.dart';
import '../../menu_options/feedback/feedback_screen.dart';
import '../../menu_options/privacy_policy/privacy_policy.dart';
import '../../menu_options/about/about_screen.dart';
import '../../menu_options/help_&_Support/help_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onCategoriesChanged;

  const AppDrawer({
    super.key,
    required this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 12, left: 1, bottom: 1),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 34, 32, 19),
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            top: BorderSide(color: Color(0xFFF7DF27), width: 1.2),
            right: BorderSide(color: Color(0xFFF7DF27), width: 1.2),
            bottom: BorderSide(color: Color(0xFFF7DF27), width: 1.2),
          ),
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
              offset: const Offset(9, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFFF7DF27), Color(0xFFF7DF27)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              Icons.settings,
              'Settings',
              onTap: () async {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
                final prefs = await SharedPreferences.getInstance();
                bool? categoriesChanged = prefs.getBool('categoriesChanged');
                if (categoriesChanged == true) {
                  onCategoriesChanged();
                  await prefs.setBool('categoriesChanged', false);
                }
              },
            ),
            _buildDrawerItem(
              context,
              Icons.star_border,
              'Rate Us',
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RateUsScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.feedback_outlined,
              'Feedback',
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeedbackScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.info_outline,
              'About',
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              Icons.help_outline,
              'Help & Support',
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),
            TapFeedbackHelpers.feedbackListTile(
              context: context,
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                FocusScope.of(context).unfocus();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('currentUserEmail');
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              backgroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return TapFeedbackHelpers.feedbackListTile(
      context: context,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      onTap: onTap,
      backgroundColor: Colors.black,
    );
  }
}