import 'package:flutter/material.dart';
import '../constants/app_styles.dart';

class QQHeader extends StatelessWidget {
  const QQHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.color,
    this.leading,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Color? color;
  final Widget? leading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, compact ? 20 : 28, 24, compact ? 24 : 32),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading != null) ...[leading!, const SizedBox(height: 8)],
            Text(title, textAlign: TextAlign.center, style: AppStyles.headerTitle),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: AppStyles.headerSubtitle),
          ],
        ),
      ),
    );
  }
}
