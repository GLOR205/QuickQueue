import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/location_entity.dart';
import 'locations_screen.dart';

/// Landing step of the "find a queue" flow: pick hospital or bank services
/// before seeing individual locations.
class LocationCategoriesScreen extends StatelessWidget {
  const LocationCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          const QQHeader(
            title: AppStrings.whereAreYouGoing,
            subtitle: AppStrings.chooseCategorySubtitle,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: colors.primary),
                        const SizedBox(width: 6),
                        Text(AppStrings.backToHome,
                            style: AppStyles.link(context)),
                      ],
                    ),
                  ),
                ),
                _CategoryCard(
                  icon: Icons.local_hospital_outlined,
                  accent: colors.avatarPalette[0],
                  title: 'Hospital Services',
                  subtitle: 'Consultations, labs, pharmacy & more',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocationsScreen(
                          category: LocationCategory.hospital),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _CategoryCard(
                  icon: Icons.account_balance_outlined,
                  accent: colors.avatarPalette[1],
                  title: 'Bank Services',
                  subtitle: 'Tellers, account services & more',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocationsScreen(
                          category: LocationCategory.bank),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppStyles.cardTitle(context)
                            .copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppStyles.bodyMuted(context)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
