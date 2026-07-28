import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Placeholder entry point for staff/admin sign-in. Lydivine owns the real
/// staff screens (queue dashboard, skip, analytics, pause queue, staff
/// profile) and the StaffBloc wiring — this just gives the nav a real
/// destination in the meantime so "Login as admin" from the Index screen
/// doesn't dead-end.
class StaffLoginScreen extends StatelessWidget {
  const StaffLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          const QQHeader(
            title: 'Staff Login',
            subtitle: 'Sign in to manage your queue',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(AppStrings.backToHome, style: AppStyles.link(context)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined,
                        size: 56, color: colors.textMuted),
                    const SizedBox(height: 16),
                    Text('Staff login coming soon',
                        style: AppStyles.sectionTitle(context)),
                    const SizedBox(height: 8),
                    Text(
                      "This screen is being built out separately for staff accounts.",
                      textAlign: TextAlign.center,
                      style: AppStyles.bodyMuted(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
