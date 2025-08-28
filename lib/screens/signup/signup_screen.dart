import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import '../../constants/theme_color.dart';
import '../login/login_screen.dart';
import '../../constants/text_field_with_validation.dart';
import '../../constants/tap_feedback_helpers.dart';
import '../menu_options/privacy_policy/privacy_policy.dart';
import '../menu_options/terms_of_service/terms_of_service_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form validation
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers and focus nodes
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  // UI state
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_handleFocusChange);
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Handle focus changes for UI updates
  void _handleFocusChange() {
    if (_nameFocusNode.hasFocus) {
      setState(() {});
    }
    if (_emailFocusNode.hasFocus) {
      setState(() {});
    }
    if (_passwordFocusNode.hasFocus) {
      setState(() {});
    }
  }

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
              color: isError ? Colors.redAccent : AppColors.primaryYellow,
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
                color: isError ? Colors.redAccent : AppColors.primaryYellow,
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

  // Handle user registration
  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_acceptedTerms) {
      _showSnack("Please accept the Privacy Policy and Terms of Service", isError: true);
      return;
    }
    
    if (!_canSignUp) {
      return;
    }
    
    // Additional comprehensive validation
    if (!_isFormValid()) {
      return;
    }
    
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('allUsers');
    Map<String, dynamic> allUsers =
        usersJson != null ? jsonDecode(usersJson) : {};
    if (allUsers.containsKey(email)) {
      _formKey.currentState!.validate();
      return;
    }
    
    allUsers[email] = {'name': name, 'password': password};
    await prefs.setString('allUsers', jsonEncode(allUsers));
    await prefs.setString('currentUserEmail', email);
    await prefs.setString('userName_$email', name);
    _showSnack("Account created successfully!", isError: false);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
  
   bool get _canSignUp =>
       _nameController.text.trim().isNotEmpty &&
       _emailController.text.trim().isNotEmpty &&
       _passwordController.text.trim().isNotEmpty;

  bool _isFormValid() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    return name.isNotEmpty &&
           email.isNotEmpty &&
           password.isNotEmpty &&
           password.length >= 6 &&
           email.contains('@gmail.com') &&
           _acceptedTerms;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTop = MediaQuery.of(context).size.height * 0.15;
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (!didPop) {
              final node = FocusManager.instance.primaryFocus;
              if (node != null && node.hasFocus) {
                node.unfocus();
              }
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.backgroundBlack,
            body: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  top: isKeyboardVisible ? 0 : defaultTop,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CustomBlackYellowTextField(
                                    label: 'Full Name',
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                                    autofillHints: const [AutofillHints.name],
                                    textCapitalization: TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) return 'Please enter your full name';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CustomBlackYellowTextField(
                                    label: 'Email',
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                                    autofillHints: const [AutofillHints.email],
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) return 'Please enter your email';
                                      if (!value.contains('@gmail.com')) return 'Please enter a valid email (e.g. example@gmail.com)';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CustomBlackYellowTextField(
                                    label: 'Password',
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                      if (_isFormValid()) {
                                        _handleSignUp();
                                      }
                                    },
                                    autofillHints: const [AutofillHints.newPassword],
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    suffixIcon: TapFeedbackHelpers.feedbackIconButton(
                                      context: context,
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white54,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white54.withValues(alpha: 0.3),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) return 'Please enter a password';
                                      if (value.length < 6) return 'Password must be at least 6 chars';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _acceptedTerms = !_acceptedTerms;
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _acceptedTerms ? AppColors.primaryYellow : Colors.transparent,
                                            border: Border.all(
                                              color: _acceptedTerms ? AppColors.primaryYellow : Colors.white70,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: _acceptedTerms
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              const TextSpan(text: 'I accept the '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: const TextStyle(
                                                  color: AppColors.primaryYellow,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => const PrivacyPolicyScreen(),
                                                      ),
                                                    );
                                                  },
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: const TextStyle(
                                                  color: AppColors.primaryYellow,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => const TermsOfServiceScreen(),
                                                      ),
                                                    );
                                                  },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  SizedBox(
                                     width: double.infinity,
                                     height: 50,
                                     child: _canSignUp
                                         ? TapFeedbackHelpers.feedbackButton(
                                             context: context,
                                             onPressed: _handleSignUp,
                                             backgroundColor: AppColors.primaryYellow,
                                             foregroundColor: Colors.black,
                                             borderRadius: BorderRadius.circular(12),
                                             child: Text(
                                               'Sign Up',
                                               overflow: TextOverflow.ellipsis,
                                               style: const TextStyle(
                                                 fontSize: 18,
                                                 fontWeight: FontWeight.bold,
                                                 color: Colors.black,
                                               ),
                                             ),
                                           )
                                         : Container(
                                             decoration: BoxDecoration(
                                               color: Colors.grey[800],
                                               borderRadius: BorderRadius.circular(12),
                                             ),
                                             alignment: Alignment.center,
                                             child: Text(
                                               'Sign Up',
                                               overflow: TextOverflow.ellipsis,
                                               style: TextStyle(
                                                 fontSize: 18,
                                                 fontWeight: FontWeight.bold,
                                                 color: Colors.grey[100],
                                               ),
                                             ),
                                           ),
                                   ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Already have an account?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      TapFeedbackHelpers.feedbackTextButton(
                                        context: context,
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          );
                                        },
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: AppColors.primaryYellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
