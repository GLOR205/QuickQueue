import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

enum QQNavTab { ticket, alerts, profile }

class QQBottomNav extends StatelessWidget {
  const QQBottomNav({super.key, required this.current, required this.onTabSelected});

  final QQNavTab current;
  final ValueChanged<QQNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Ticket',
                selected: current == QQNavTab.ticket,
                onTap: () => onTabSelected(QQNavTab.ticket),
              ),
              _NavItem(
                icon: Icons.notifications_none_rounded,
                label: 'Alerts',
                selected: current == QQNavTab.alerts,
                onTap: () => onTabSelected(QQNavTab.alerts),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: current == QQNavTab.profile,
                onTap: () => onTabSelected(QQNavTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primary : colors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: AppStyles.caption(context).copyWith(color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
