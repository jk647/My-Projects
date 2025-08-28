import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme_color.dart';
import 'dart:convert';
import '../../constants/CustomLoginTextField.dart';
import '../../constants/tap_feedback_helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Form controller
  final TextEditingController _emailController = TextEditingController();
  
  // UI state
  String? _retrievedPassword;
  bool _isChecking = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  // Handle password retrieval
  Future<void> _handleForgotPassword() async {
    final enteredEmail = _emailController.text.trim();

    setState(() {
      _emailError = null;
      _retrievedPassword = null;
    });

    if (enteredEmail.isEmpty) {
      setState(() {
        _emailError = "Please enter your email.";
      });
      return;
    }

    setState(() {
      _isChecking = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? usersJson = prefs.getString('allUsers');
    Map<String, dynamic> allUsers =
        usersJson != null ? jsonDecode(usersJson) : {};

    await Future.delayed(const Duration(seconds: 1));

    if (allUsers.containsKey(enteredEmail)) {
      final savedPassword = allUsers[enteredEmail]['password'];
      setState(() {
        _retrievedPassword = savedPassword;
        _isChecking = false;
      });
      _showSnack(
        "Password retrieved successfully!",
        isError: false,
        icon: Icons.check_circle_outline,
      );
    } else {
      setState(() {
        _emailError = "No account found with this email.";
        _retrievedPassword = null;
        _isChecking = false;
      });
      return;
    }
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
          "Forgot Password",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "Enter your registered email to view your password",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomLoginTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onChanged: (value) {
                if (_emailError != null && value.isNotEmpty) {
                  setState(() {
                    _emailError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isChecking
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
                        onTap: _handleForgotPassword,
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.black.withOpacity(0.3),
                        highlightColor: Colors.black.withOpacity(0.1),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Retrieve Password",
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
            const SizedBox(height: 30),
            if (_retrievedPassword != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      "Your password: $_retrievedPassword",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
