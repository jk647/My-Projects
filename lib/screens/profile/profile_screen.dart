import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskura_app/main.dart';
import '../../constants/theme_color.dart';
import '../../models/task_model.dart';
import '../../constants/app_decor.dart';
import '../../constants/tap_feedback_helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  // User data
  String _userEmail = '';
  String _userName = '';
  int _totalTasks = 0;
  int _completedTasks = 0;

  // Profile image
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Custom snackbar for user feedback
  void _showSnack(String message, {bool isError = false, IconData? icon}) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      final snackBar = SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: isError ? Colors.redAccent : const Color(0xFFF7DF27),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon ??
                    (isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline),
                color: isError ? Colors.redAccent : const Color(0xFFF7DF27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
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
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Load user data and profile
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUserEmail') ?? 'guest@taskura.com';
    final name = prefs.getString('userName_$email') ?? 'Your Name';

    setState(() {
      _userEmail = email;
      _userName = name;
    });

    _loadProfileImage(email);
    _loadTaskStats();
  }

  // Load task statistics from Hive
  Future<void> _loadTaskStats() async {
    final boxName = 'tasksBox_$_userEmail';

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<TaskModel>(boxName);
    }

    final taskBox = Hive.box<TaskModel>(boxName);
    final allTasks = taskBox.values.where(
      (task) => task.userEmail == _userEmail,
    );

    setState(() {
      _totalTasks = allTasks.length;
      _completedTasks = allTasks.where((task) => task.isDone).length;
    });
  }

  // Load profile image from storage
  Future<void> _loadProfileImage(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImagePath_$email');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Save profile image path to storage
  Future<void> _saveProfileImage(String email, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath_$email', imagePath);
    setState(() {
      _profileImage = File(imagePath);
    });
  }

  // Show image picker options
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          decoration: AppDecor.yellowBox,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                                 TapFeedbackHelpers.feedbackListTile(
                   context: context,
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryYellow,
                  ),
                  title: const Text(
                    "Take a Photo",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                   backgroundColor: Colors.black,
                ),
                 TapFeedbackHelpers.feedbackListTile(
                   context: context,
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primaryYellow,
                  ),
                  title: const Text(
                    "Choose from Gallery",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                   backgroundColor: Colors.black,
                ),
                TapFeedbackHelpers.feedbackListTile(
                  context: context,
                  leading: const Icon(
                    Icons.delete,
                    color: AppColors.primaryYellow,
                  ),
                  title: const Text(
                    "Remove Photo",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('profileImagePath_$_userEmail');

                    setState(() {
                      _profileImage = null;
                    });

                    await Future.delayed(const Duration(milliseconds: 200));
                    Navigator.pop(context, true);
                  },
                  backgroundColor: Colors.black,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
    final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      
    if (image != null) {
        final croppedFile = await _cropImage(image.path);
        if (croppedFile != null) {
          await _saveProfileImage(_userEmail, croppedFile.path);
        }
      }
    } catch (e) {
      _showSnack(
        'Failed to update profile photo',
        isError: true,
        icon: Icons.error_outline,
      );
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath) async {
    try {
      return await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.black,
            toolbarWidgetColor: const Color(0xFFF7DF27),
            backgroundColor: Colors.black,
            lockAspectRatio: true,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.square,
            statusBarColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFFF7DF27),
            cropFrameColor: const Color(0xFFF7DF27),
            cropGridColor: const Color(0xFFF7DF27).withOpacity(0.5),
            cropGridColumnCount: 3,
            cropGridRowCount: 3,
          ),
          IOSUiSettings(
            title: '',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            hidesNavigationBar: false,
          ),
        ],
      );
    } catch (e) {
      return CroppedFile(imagePath);
    }
  }

  void _showProfilePhotoPreview() {
    if (_profileImage == null) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _ProfilePhotoPreviewScreen(
            profileImage: _profileImage!,
            animation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
Future<void> _saveName(String newName) async {
    if (newName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName_$_userEmail', newName);
      setState(() => _userName = newName);
    }
  }

  @override
  void didPushNext() {
    FocusScope.of(context).unfocus();
  }

  @override
  void didPopNext() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _editNameDialog() async {
    final controller = TextEditingController(text: _userName);
    await showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: AppDecor.blackBox,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Name',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryYellow,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onEditingComplete: () {
                      _saveName(controller.text.trim());
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TapFeedbackHelpers.feedbackTextButton(
                        context: context,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TapFeedbackHelpers.feedbackTextButton(
                        context: context,
                        onPressed: () {
                          _saveName(controller.text.trim());
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: AppColors.primaryYellow),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
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
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
                     GestureDetector(
             onTap: _profileImage != null ? _showProfilePhotoPreview : null,
             child: Hero(
               tag: 'profile_photo',
               child: CircleAvatar(
                 radius: 55,
                 backgroundColor: const Color(0xFFF7DF27),
                 backgroundImage:
                     _profileImage != null ? FileImage(_profileImage!) : null,
                 child:
                     _profileImage == null
                         ? const Icon(Icons.person, color: Colors.black, size: 40)
                         : null,
               ),
             ),
           ),

          const SizedBox(height: 10),
          TapFeedbackHelpers.tapFeedbackContainer(
            context: context,
            onTap: _showImagePickerOptions,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Edit',
              style: GoogleFonts.poppins(
                  color: const Color(0xFFF7DF27),
                fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileItem(
                    icon: Icons.person,
                    label: 'Name',
                    value: _userName,
                  trailing: TapFeedbackHelpers.feedbackIconButton(
                    context: context,
                    onPressed: _editNameDialog,
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white70.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: _userEmail,
                ),
                const SizedBox(height: 24),
                _buildProfileItem(
                  icon: Icons.assignment,
                  label: 'Total Tasks',
                  value: _totalTasks.toString(),
                ),
                const SizedBox(height: 24),
                _buildProfileItem(
                  icon: Icons.check_circle,
                  label: 'Completed Tasks',
                  value: _completedTasks.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryYellow),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}

class _ProfilePhotoPreviewScreen extends StatefulWidget {
  final File profileImage;
  final Animation<double> animation;

  const _ProfilePhotoPreviewScreen({
    required this.profileImage,
    required this.animation,
  });

  @override
  State<_ProfilePhotoPreviewScreen> createState() => _ProfilePhotoPreviewScreenState();
}

class _ProfilePhotoPreviewScreenState extends State<_ProfilePhotoPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Hero(
            tag: 'profile_photo',
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: InteractiveViewer(
                    child: Image.file(
                      widget.profileImage,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),
           Positioned(
             top: MediaQuery.of(context).padding.top + 16,
             right: 16,
             child: AnimatedBuilder(
               animation: widget.animation,
               builder: (context, child) {
                 return Opacity(
                   opacity: widget.animation.value,
                   child: Container(
                     decoration: BoxDecoration(
                       color: Colors.black.withOpacity(0.7),
                       borderRadius: BorderRadius.circular(20),
                     ),
                                           child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                       icon: const Icon(Icons.close, color: Colors.white, size: 24),
                       padding: const EdgeInsets.all(8),
                     ),
                   ),
                 );
               },
             ),
           ),
        ],
      ),
    );
  }
}
