import 'package:flutter/material.dart';

/// Staff portal palette, matching the staff-screens Figma designs. Kept
/// separate from the customer-facing AppColorsExt since the staff portal
/// has its own visual identity (indigo vs. the customer app's navy).
class StaffColors {
  StaffColors._();

  static const primary = Color(0xFF5B4FE0);
  static const primaryLight = Color(0xFFEDEAFC);
  static const background = Color(0xFFF5F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E4EA);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B7B);
  static const textMuted = Color(0xFF9B9BA8);
  static const success = Color(0xFF1E9E5A);
  static const successLight = Color(0xFFE3F7EC);
  static const danger = Color(0xFFD4423C);
  static const dangerLight = Color(0xFFFBE9E8);
  static const warning = Color(0xFFB9721B);
  static const warningLight = Color(0xFFFDF0E0);
}
