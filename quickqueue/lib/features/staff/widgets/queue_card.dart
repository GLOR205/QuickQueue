import 'package:flutter/material.dart';

import '../presentation/widgets/staff_colors.dart';

class QueueCard extends StatelessWidget {
  const QueueCard({
    super.key,
    required this.customer,
    required this.position,
    required this.onTap,
  });

  final String customer;
  final int position;
  final VoidCallback onTap;

  String get _badgeLabel {
    switch (position) {
      case 1:
        return 'Now';
      case 2:
        return 'Next';
      default:
        return _ordinal(position);
    }
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = position == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isCurrent ? StaffColors.primaryLight : StaffColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent
                    ? StaffColors.primary.withValues(alpha: 0.3)
                    : StaffColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    customer,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? StaffColors.primary
                          : StaffColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? StaffColors.primary
                        : StaffColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _badgeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? Colors.white : StaffColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
