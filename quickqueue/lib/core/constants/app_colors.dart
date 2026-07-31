import 'package:flutter/material.dart';

@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.error,
    required this.errorLight,
    required this.star,
    required this.avatarPalette,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;

  final Color background;
  final Color surface;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color success;
  final Color successLight;

  final Color warning;
  final Color warningLight;

  final Color error;
  final Color errorLight;

  final Color star;

  final List<Color> avatarPalette;

  static const light = AppColorsExt(
    primary: Color(0xFF1B4C8C),
    primaryDark: Color(0xFF123A6E),
    primaryLight: Color(0xFFE7F0FB),
    background: Color(0xFFF5F6F8),
    surface: Colors.white,
    border: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    success: Color(0xFF2E9E5B),
    successLight: Color(0xFFE6F4EA),
    warning: Color(0xFFEE9D2B),
    warningLight: Color(0xFFFBEEDB),
    error: Color(0xFFD64545),
    errorLight: Color(0xFFFBE9E9),
    star: Color(0xFFF0A93C),
    avatarPalette: [
      Color(0xFF2B7A78),
      Color(0xFF6C63B5),
      Color(0xFF3E8E5A),
      Color(0xFF3D6FB4),
    ],
  );

  static const dark = AppColorsExt(
    primary: Color(0xFF5B8DEF),
    primaryDark: Color(0xFF3E6BC4),
    primaryLight: Color(0xFF1E2A44),
    background: Color(0xFF101319),
    surface: Color(0xFF1B1F27),
    border: Color(0xFF2C313C),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFFAEB4BF),
    textMuted: Color(0xFF767C88),
    success: Color(0xFF4CBB7C),
    successLight: Color(0xFF17301F),
    warning: Color(0xFFF2B25A),
    warningLight: Color(0xFF3A2A14),
    error: Color(0xFFE5716B),
    errorLight: Color(0xFF3A1E1D),
    star: Color(0xFFF2B25A),
    avatarPalette: [
      Color(0xFF3F9C99),
      Color(0xFF8B82D6),
      Color(0xFF5CAE7C),
      Color(0xFF5F8FD1),
    ],
  );

  @override
  AppColorsExt copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? error,
    Color? errorLight,
    Color? star,
    List<Color>? avatarPalette,
  }) {
    return AppColorsExt(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      star: star ?? this.star,
      avatarPalette: avatarPalette ?? this.avatarPalette,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return AppColorsExt(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      star: Color.lerp(star, other.star, t)!,
      avatarPalette: other.avatarPalette,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// Theme-aware design tokens — swaps automatically between [AppColorsExt.light]
  /// and [AppColorsExt.dark] as the app's [ThemeMode] changes.
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>() ?? AppColorsExt.light;
}
