import 'package:flutter/material.dart';

/// CheckIt color palette — indigo/purple tones matching the reference mockups.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryLight = Color(0xFF818CF8); // indigo-400
  static const Color primaryDark = Color(0xFF3730A3); // indigo-800

  static const Color secondary = Color(0xFF8B5CF6); // violet-500

  static const Color background = Color(0xFFF6F5FC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1E1B3A);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color border = Color(0xFFE5E3F5);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
