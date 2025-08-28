import 'package:flutter/material.dart';

// Custom tap feedback system
class CustomTapFeedback {
  // Animation duration
  static const Duration feedbackDuration = Duration(milliseconds: 200);
  
  // Feedback colors
  static const Color _yellowFeedback = Color(0xFFE6C823);
  static const Color _blackFeedback = Color(0xFFF7DF27);
  static const Color _darkFeedback = Color(0xFF4A4A4A);
  
  // Show feedback and execute action
  static Future<void> showFeedbackAndExecute(
    BuildContext context,
    VoidCallback action, {
    Color? backgroundColor,
    Color? foregroundColor,
    Offset? tapPosition,
  }) async {
    await showFeedback(
      context,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tapPosition: tapPosition,
    );
    
    action();
  }
  
  // Display tap feedback animation
  static Future<void> showFeedback(
    BuildContext context, {
    Color? backgroundColor,
    Color? foregroundColor,
    Offset? tapPosition,
  }) async {
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) return;
    
    if (renderObject is! RenderBox) {
      await Future.delayed(feedbackDuration);
      return;
    }
    
    final RenderBox renderBox = renderObject;
    final Size size = renderBox.size;
    final Offset globalOffset = renderBox.localToGlobal(Offset.zero);
    final Offset localPosition = tapPosition ?? Offset(size.width / 2, size.height / 2);
    
    // Check for problematic areas and adjust position
    final bool isProblematicArea = _isProblematicArea(context);
    final Offset adjustedPosition = isProblematicArea 
        ? Offset(-100, -100)
        : localPosition;
    
    final OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned(
        left: globalOffset.dx + adjustedPosition.dx - 25,
        top: globalOffset.dy + adjustedPosition.dy - 25,
        child: _TapFeedbackWidget(
          backgroundColor: backgroundColor ?? _getDefaultBackgroundColor(context),
          foregroundColor: foregroundColor ?? _getDefaultForegroundColor(context),
        ),
      ),
    );

    Overlay.of(context)!.insert(entry);

    await Future.delayed(feedbackDuration);

    entry.remove();
  }
  
  // Detect problematic areas for feedback
  static bool _isProblematicArea(BuildContext context) {
    final String routeName = ModalRoute.of(context)?.settings.name ?? '';
    final String currentRoute = routeName.toLowerCase();
    
    return currentRoute.contains('drawer') || 
           currentRoute.contains('add') || 
           currentRoute.contains('task') ||
           currentRoute.contains('login') ||
           currentRoute.contains('signup') ||
           currentRoute.contains('sign_up') ||
           currentRoute.contains('profile') ||
           currentRoute.contains('forgot') ||
           currentRoute.contains('password') ||
           currentRoute.contains('about') ||
           currentRoute.contains('help') ||
           currentRoute.contains('support') ||
           currentRoute.contains('privacy') ||
           currentRoute.contains('terms') ||
           currentRoute.contains('feedback') ||
           currentRoute.contains('rate') ||
           currentRoute.contains('settings') ||
           currentRoute.contains('video') ||
           currentRoute.contains('audio') ||
           currentRoute.contains('player') ||
           currentRoute.contains('dropdown') ||
           currentRoute.contains('custom') ||
           currentRoute.contains('splash') ||
           currentRoute.contains('home') ||
           _isInDrawerContext(context) ||
           _isInAddTaskContext(context) ||
           _isInLoginContext(context) ||
           _isInSignupContext(context) ||
           _isInProfileContext(context) ||
           _isInForgotPasswordContext(context) ||
           _isInMenuOptionsContext(context) ||
           _isInMediaPlayerContext(context) ||
           _isInCustomDropdownContext(context) ||
           _isInSplashContext(context) ||
           _isInHomeContext(context);
  }
  
  // Check if in drawer context
  static bool _isInDrawerContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('drawer') || 
             widgetType.contains('listtile') ||
             _hasDrawerAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in add task context
  static bool _isInAddTaskContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('addtask') || 
             widgetType.contains('add_task') ||
             _hasAddTaskAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check for drawer ancestor widget
  static bool _hasDrawerAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorWidgetOfExactType<Drawer>();
      return ancestor != null;
    } catch (e) {
      return false;
    }
  }
  
  // Check for add task ancestor widget
  static bool _hasAddTaskAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('addtask') || ancestorType.contains('add_task');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check if in login context
  static bool _isInLoginContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('login') || 
             widgetType.contains('loginscreen') ||
             _hasLoginAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in signup context
  static bool _isInSignupContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('signup') || 
             widgetType.contains('sign_up') ||
             widgetType.contains('signupscreen') ||
             _hasSignupAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in profile context
  static bool _isInProfileContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('profile') || 
             widgetType.contains('profilescreen') ||
             _hasProfileAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in forgot password context
  static bool _isInForgotPasswordContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('forgot') || 
             widgetType.contains('password') ||
             widgetType.contains('forgotpassword') ||
             _hasForgotPasswordAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in menu options context
  static bool _isInMenuOptionsContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('about') || 
             widgetType.contains('help') ||
             widgetType.contains('support') ||
             widgetType.contains('privacy') ||
             widgetType.contains('terms') ||
             widgetType.contains('feedback') ||
             widgetType.contains('rate') ||
             widgetType.contains('settings') ||
             _hasMenuOptionsAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in media player context
  static bool _isInMediaPlayerContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('video') || 
             widgetType.contains('audio') ||
             widgetType.contains('player') ||
             widgetType.contains('videoplayer') ||
             widgetType.contains('audioplayer') ||
             _hasMediaPlayerAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check for login ancestor widget
  static bool _hasLoginAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('login') || ancestorType.contains('loginscreen');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for signup ancestor widget
  static bool _hasSignupAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('signup') || 
               ancestorType.contains('sign_up') || 
               ancestorType.contains('signupscreen');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for profile ancestor widget
  static bool _hasProfileAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('profile') || ancestorType.contains('profilescreen');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for forgot password ancestor widget
  static bool _hasForgotPasswordAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('forgot') || 
               ancestorType.contains('password') || 
               ancestorType.contains('forgotpassword');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for menu options ancestor widget
  static bool _hasMenuOptionsAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('about') || 
               ancestorType.contains('help') || 
               ancestorType.contains('support') || 
               ancestorType.contains('privacy') || 
               ancestorType.contains('terms') || 
               ancestorType.contains('feedback') || 
               ancestorType.contains('rate') || 
               ancestorType.contains('settings');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for media player ancestor widget
  static bool _hasMediaPlayerAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('video') || 
               ancestorType.contains('audio') || 
               ancestorType.contains('player') || 
               ancestorType.contains('videoplayer') || 
               ancestorType.contains('audioplayer');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check if in custom dropdown context
  static bool _isInCustomDropdownContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('dropdown') || 
             widgetType.contains('custom') ||
             widgetType.contains('customdropdown') ||
             _hasCustomDropdownAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in splash context
  static bool _isInSplashContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('splash') || 
             widgetType.contains('splashscreen') ||
             _hasSplashAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check if in home context
  static bool _isInHomeContext(BuildContext context) {
    try {
      final widget = context.widget;
      final widgetType = widget.runtimeType.toString().toLowerCase();
      return widgetType.contains('home') || 
             widgetType.contains('homescreen') ||
             _hasHomeAncestor(context);
    } catch (e) {
      return false;
    }
  }
  
  // Check for custom dropdown ancestor widget
  static bool _hasCustomDropdownAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('dropdown') || 
               ancestorType.contains('custom') || 
               ancestorType.contains('customdropdown');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for splash ancestor widget
  static bool _hasSplashAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('splash') || ancestorType.contains('splashscreen');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check for home ancestor widget
  static bool _hasHomeAncestor(BuildContext context) {
    try {
      final ancestor = context.findAncestorStateOfType<State>();
      if (ancestor != null) {
        final ancestorType = ancestor.runtimeType.toString().toLowerCase();
        return ancestorType.contains('home') || ancestorType.contains('homescreen');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Get default background color
  static Color _getDefaultBackgroundColor(BuildContext context) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return _yellowFeedback;
    }
    return _darkFeedback;
  }
  
  // Get default foreground color
  static Color _getDefaultForegroundColor(BuildContext context) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return _blackFeedback;
    }
    return _yellowFeedback;
  }
  
  // Wrap widget with tap feedback
  static Widget wrapWithFeedback({
    required BuildContext context,
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showFeedbackAndExecute(
          context,
          onTap,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        splashColor: foregroundColor ?? _blackFeedback,
        highlightColor: backgroundColor ?? _darkFeedback,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
  
  // Create button with tap feedback
  static Widget button({
    required BuildContext context,
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null ? null : () => showFeedbackAndExecute(
            context,
            onPressed,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          borderRadius: borderRadius,
          splashColor: foregroundColor ?? _blackFeedback,
          highlightColor: backgroundColor ?? _darkFeedback,
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: borderRadius,
            ),
            child: Container(
              padding: padding,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Tap feedback animation widget
class _TapFeedbackWidget extends StatefulWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  
  const _TapFeedbackWidget({
    required this.backgroundColor,
    required this.foregroundColor,
  });
  
  @override
  State<_TapFeedbackWidget> createState() => _TapFeedbackWidgetState();
}

class _TapFeedbackWidgetState extends State<_TapFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      duration: CustomTapFeedback.feedbackDuration,
      vsync: this,
    );
    
    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgroundColor.withOpacity(0.3),
                border: Border.all(
                  color: widget.foregroundColor.withOpacity(0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}