import 'package:flutter/material.dart';
import 'custom_tap_feedback.dart';

class TapFeedbackHelpers {
  static Widget tapFeedbackContainer({
    required BuildContext context,
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CustomTapFeedback.showFeedbackAndExecute(
          context,
          onTap,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
        highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget feedbackButton({
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
    if (onPressed == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CustomTapFeedback.showFeedbackAndExecute(
            context,
            onPressed,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          borderRadius: borderRadius,
          splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
          highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
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

  static Widget feedbackListTile({
    required BuildContext context,
    required Widget leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? backgroundColor,
    EdgeInsetsGeometry? contentPadding,
  }) {
    if (onTap == null) {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        contentPadding: contentPadding,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CustomTapFeedback.showFeedbackAndExecute(
          context,
          onTap,
          backgroundColor: backgroundColor,
          foregroundColor: backgroundColor != null ? Colors.white : null,
        ),
        splashColor: const Color(0xFFF7DF27).withOpacity(0.3),
        highlightColor: const Color(0xFF4A4A4A).withOpacity(0.3),
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          contentPadding: contentPadding,
        ),
      ),
    );
  }

  static Widget feedbackIconButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required Icon icon,
    Color? backgroundColor,
    Color? foregroundColor,
    double? size,
    EdgeInsetsGeometry? padding,
  }) {
    if (onPressed == null) {
      return Container(
        width: size ?? 48,
        height: size ?? 48,
        padding: padding,
        child: icon,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CustomTapFeedback.showFeedbackAndExecute(
          context,
          onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        borderRadius: BorderRadius.circular(size ?? 24),
        splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
        highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(size ?? 24),
          ),
          child: Container(
            width: size ?? 48,
            height: size ?? 48,
            padding: padding,
            child: icon,
          ),
        ),
      ),
    );
  }

  static Widget feedbackCard({
    required BuildContext context,
    required Widget child,
    required VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
  }) {
    if (onTap == null && onLongPress == null) {
      return Container(
        margin: margin,
        padding: padding,
        child: child,
      );
    }

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null ? null : () => CustomTapFeedback.showFeedbackAndExecute(
            context,
            onTap,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          onLongPress: onLongPress,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
          highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              boxShadow: elevation != null ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Container(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  static Widget wrapButtonWithFeedback({
    required BuildContext context,
    required Widget button,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    if (onPressed == null) {
      return button;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CustomTapFeedback.showFeedbackAndExecute(
          context,
          onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
        highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
        child: button,
      ),
    );
  }

  static Widget feedbackTextButton({
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
    if (onPressed == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CustomTapFeedback.showFeedbackAndExecute(
            context,
            onPressed,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
          highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  static Widget feedbackChip({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CustomTapFeedback.showFeedbackAndExecute(
            context,
            onTap,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          splashColor: foregroundColor ?? const Color(0xFFF7DF27).withOpacity(0.3),
          highlightColor: backgroundColor ?? const Color(0xFF4A4A4A).withOpacity(0.3),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: borderRadius ?? BorderRadius.circular(20),
            ),
            child: Container(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}