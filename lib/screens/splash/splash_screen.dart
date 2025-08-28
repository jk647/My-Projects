import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme_color.dart';

// App splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;
  
  // Loading state
  double _progressValue = 0.0;
  bool _imagePrecached = false;

  @override
  void initState() {
    super.initState();

    // Initialize logo animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Scale animation for logo
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(_logoController);

    _startLoading();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Precache logo image
    if (!_imagePrecached) {
      precacheImage(const AssetImage('assets/images/logo.png'), context);
      _imagePrecached = true;
    }
  }

  // Start loading timer
  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progressValue += 0.025;
        if (_progressValue >= 1.0) {
          timer.cancel();
          _navigateNext();
        }
      });
    });
  }

  // Navigate to appropriate screen
  Future<void> _navigateNext() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final String? currentUserEmail = prefs.getString('currentUserEmail');

    // Set first time flag
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }

    if (!mounted) return;

    // Navigate based on user state
    if (currentUserEmail != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/images/logo.png',
            height: 100,
            width: 100,
          ),
        ),
      ),
    );
  }
}
