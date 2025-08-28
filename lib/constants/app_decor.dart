import 'package:flutter/material.dart';

class AppDecor {
  static BoxDecoration yellowBox = BoxDecoration(
    color: const Color.fromARGB(255, 34, 32, 19),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFF7DF27), width: 1.2),
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
  );

  static BoxDecoration blackBox = BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFF7DF27), width: 1.2),
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
  );

  static BoxDecoration inputBox = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFF7DF27), width: 1.2),
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
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration modalSheet = BoxDecoration(
    color: Colors.black,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    border: Border.all(
      color: const Color(0xFFF7DF27).withOpacity(0.8),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
