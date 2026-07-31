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

  /// Forces the staff portal to a consistent light theme regardless of the
  /// device/app-wide theme (which may be dark). Every staff screen wraps its
  /// Scaffold in this — without it, unstyled Material defaults (like a
  /// disabled button's colors) fall back to the ambient app theme, which can
  /// clash badly with the staff portal's hardcoded light colors when the
  /// system is in dark mode (e.g. white text on a white button).
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    );
  }
}
