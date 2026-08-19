import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color:      const Color(0xFF0E2438).withValues(alpha: 0.28),
          blurRadius: 24,
          spreadRadius: -12,
          offset:     const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get small => [
        BoxShadow(
          color:      const Color(0xFF0E2438).withValues(alpha: 0.10),
          blurRadius: 10,
          offset:     const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color:      const Color(0xFF0E2438).withValues(alpha: 0.35),
          blurRadius: 30,
          spreadRadius: -10,
          offset:     const Offset(0, 14),
        ),
      ];

  static List<BoxShadow> get nav => [
        BoxShadow(
          color:      const Color(0xFF0E2438).withValues(alpha: 0.55),
          blurRadius: 30,
          spreadRadius: -10,
          offset:     const Offset(0, 14),
        ),
      ];
}