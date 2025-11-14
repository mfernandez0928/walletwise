import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6C5CE7); // Purple
  static const Color primaryLight = Color(0xFF8E7EF5); // Light Purple
  static const Color secondary = Color(0xFF00B894); // Green
  static const Color accent = Color(0xFFFF6B6B); // Red
  static const Color danger = Color(0xFFFF6B6B); // Red (Error/Danger)

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF8E7EF5),
  ];

  static const List<Color> successGradient = [
    Color(0xFF00B894),
    Color(0xFF00D2A7),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFD79A8),
    Color(0xFFFF9FF3),
  ];

  static const List<Color> infoGradient = [
    Color(0xFF74B9FF),
    Color(0xFF0984E3),
  ];

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF2D2D44);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // Border & Divider
  static const Color border = Color(0xFFDFE6E9);
  static const Color divider = Color(0xFFECF0F1);

  // Shadows
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.15);

  // Account Type Colors
  static const Map<String, Color> accountTypeColors = {
    'Wallet': Color(0xFF6C5CE7),
    'Savings': Color(0xFF00B894),
    'Credit': Color(0xFFFF6B6B),
    'Investment': Color(0xFF74B9FF),
    'Loan': Color(0xFFFDCB6E),
  };
}
