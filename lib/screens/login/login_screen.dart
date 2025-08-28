import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskura_app/screens/forgotPassword/forgot_password_screen.dart';
import '../../constants/theme_color.dart';
import '../home/home_screen.dart';
import '../signup/signup_screen.dart';
import '../../constants/CustomLoginTextField.dart';
import '../../constants/tap_feedback_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form controllers and focus nodes
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  // Form validation state
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_emailFocusNode.hasFocus && _emailError != null) {
      setState(() => _emailError = null);
    }
    if (_passwordFocusNode.hasFocus && _passwordError != null) {
      setState(() => _passwordError = null);
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

  // Login authentication logic
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    
    // Check if all required fields are filled
    if (!_canLogin) {
      return;
    }
    
    // Additional comprehensive validation
    if (!_isFormValid()) {
      return;
    }
    
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      return;
    }

    // Check user credentials
    final String? usersJson = prefs.getString('allUsers');
    final allUsers =
        usersJson != null
            ? jsonDecode(usersJson) as Map<String, dynamic>
            : <String, dynamic>{};

    if (!allUsers.containsKey(email)) {
      setState(() => _emailError = 'No account found with this email');
      return;
    }

    final savedPassword = allUsers[email]['password'];
    if (savedPassword != password) {
      setState(() => _passwordError = 'Incorrect password');
      return;
    }

    // Save user session and navigate
    final existingName = prefs.getString('userName_$email');
    if (existingName == null || existingName.isEmpty) {
      await prefs.setString('userName_$email', allUsers[email]['name']);
    }

    await prefs.setString('currentUserEmail', email);
    _showSnack('Successfully logged in!', isError: false);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // Check if login button should be enabled
  bool get _canLogin =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  // Additional validation method for extra security
  bool _isFormValid() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    return email.isNotEmpty && password.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTop = MediaQuery.of(context).size.height * 0.27;
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return WillPopScope(
          onWillPop: () async {
            final focus = FocusManager.instance.primaryFocus;
            if (focus != null && focus.hasFocus) {
              focus.unfocus();
              return false;
            }
            return true;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppColors.backgroundBlack,
            body: Stack(
              children: [
                // Header section
                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          Image.asset('assets/images/logo.png', height: 85),
                          const SizedBox(height: 50),
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please login to continue',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Login form section
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  top: isKeyboardVisible ? 155 : defaultTop,
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
                            const SizedBox(height: 80),
                            CustomLoginTextField(
                              label: "Email",
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (value) {
                                if (_emailError != null && value.isNotEmpty) {
                                  setState(() => _emailError = null);
                                }
                                 setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomLoginTextField(
                              label: "Password",
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                if (_isFormValid()) {
                                  _handleLogin();
                                }
                              },
                              autofillHints: const [AutofillHints.password],
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                if (_passwordError != null && value.isNotEmpty) {
                                  setState(() => _passwordError = null);
                                }
                                setState(() {});
                              },
                              suffixIcon: TapFeedbackHelpers.feedbackIconButton(
                                context: context,
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white54.withOpacity(0.3),
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Login button with conditional styling
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: _canLogin
                                  ? TapFeedbackHelpers.feedbackButton(
                                      context: context,
                                      onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          _handleLogin();
                                      },
                                    backgroundColor: AppColors.primaryYellow,
                                    foregroundColor: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Text(
                                        'Login',
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
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                    'Login',
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
                            
                            // Navigation links
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TapFeedbackHelpers.feedbackTextButton(
                                    context: context,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: Colors.white60),
                                    ),
                                  ),
                                  const Text(
                                    '|',
                                    style: TextStyle(color: Colors.white30),
                                  ),
                                  TapFeedbackHelpers.feedbackTextButton(
                                    context: context,
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Create Account',
                                      style: TextStyle(color: Colors.white60),
                                    ),
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
