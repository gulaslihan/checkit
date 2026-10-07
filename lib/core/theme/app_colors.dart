import 'package:flutter/material.dart';

/// CheckIt color palette — "boutique" sage green + cream + charcoal, inspired
/// by Parisian shopfront/passage reference photos (2026-08 redesign).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3F6B35); // deep forest green
  static const Color primaryLight = Color(0xFFB5DAA9); // pastel sage green
  static const Color primaryDark = Color(0xFF2C4F27);

  static const Color secondary = Color(0xFFE06B45); // vivid coral/salmon
  static const Color secondaryLight = Color(0xFFFCE0CC);

  static const Color background = Color(0xFFFAF7F0); // warm cream
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF2A2A26); // warm charcoal
  static const Color textSecondary = Color(0xFF7D7A6E);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  /// Soft hairline for inputs/dividers — the graphic 1px charcoal outline
  /// (see [cardBorder]) is reserved for cards, not used everywhere.
  static const Color border = Color(0xFFE4E0D5);

  /// Thin "windowpane" outline used on cards/tiles — the recurring motif
  /// from the redesign's reference photos (crittall door/shower grids).
  static const Color cardBorder = textPrimary;
}
