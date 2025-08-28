import 'package:flutter/material.dart';
import 'dart:io';
import '../../../constants/tap_feedback_helpers.dart';
import '../../profile/profile_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfileTap;
  final VoidCallback onProfileImageReload;
  final File? profileImage;
  final FocusNode searchFocusNode;

  const HomeAppBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onMenuPressed,
    required this.onProfileTap,
    required this.onProfileImageReload,
    required this.profileImage,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: Builder(
        builder: (context) => TapFeedbackHelpers.feedbackIconButton(
          context: context,
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFFF7DF27)),
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
        ),
      ),
      title: TextField(
        focusNode: searchFocusNode,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        onChanged: onSearchChanged,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TapFeedbackHelpers.tapFeedbackContainer(
            context: context,
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              ).then((_) {
                onProfileImageReload();
              });
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF7DF27),
              backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
              child: profileImage == null
                  ? const Icon(Icons.person, color: Colors.black)
                  : null,
            ),
            backgroundColor: const Color(0xFFF7DF27).withOpacity(0.3),
            foregroundColor: Colors.black.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}