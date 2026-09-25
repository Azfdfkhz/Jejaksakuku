import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base colors
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE3E7ED);

  // Text colors
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF667085);

  // Accent colors
  static const Color primary = Color(0xFF3F7FEA);
  static const Color primaryLight = Color(0xFF7AA8F2);
  static const Color primaryDark = Color(0xFF285AB5);

  // Category & Status Colors
  static const Color pklBlue = primary;
  static const Color learningPurple = Color(0xFF7C3AED);
  static const Color learningPurpleLight = Color(0xFFA78BFA);
  static const Color personalYellow = Color(0xFFF59E0B);
  static const Color personalYellowLight = Color(0xFFFCD34D);
  static const Color completedGreen = Color(0xFF10B981);
  static const Color completedGreenLight = Color(0xFF6EE7B7);
  static const Color attentionOrange = Color(0xFFF97316);
  static const Color attentionOrangeLight = Color(0xFFFDBA74);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedLight = Color(0xFFFCA5A5);
  
  // Hover and Interactive States
  static const Color hoverPrimary = Color(0xFF3569C4);
  static const Color focusPrimary = Color(0xFF285AB5);
  static const Color disabled = Color(0xFFD1D5DB);
}
