import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_state.dart';

/// The Alerts tab body inside [HomeShell]. Reads the session-scoped
/// [QueueBloc] provided at the app root.
class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const QQHeader(
          title: AppStrings.notifications,
          subtitle: AppStrings.notificationsSubtitle,
        ),
        Expanded(
          child: BlocBuilder<QueueBloc, QueueState>(
            builder: (context, state) {
              if (state.status == QueueStatus.loading && state.notifications.isEmpty) {
                return Center(child: CircularProgressIndicator(color: context.colors.primary));
              }
              if (state.notifications.isEmpty) {
                return Center(child: Text('No notifications yet', style: AppStyles.bodyMuted(context)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _NotificationCard(notification: state.notifications[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final IconData icon;
    final Color iconBg;
    final Color iconColor;
    final Color cardBg;
    final bool isTintedCard;

    switch (notification.type) {
      case NotificationType.positionUpdate:
        icon = Icons.priority_high_rounded;
        iconBg = colors.warning;
        iconColor = Colors.white;
        cardBg = colors.warningLight;
        isTintedCard = true;
        break;
      case NotificationType.joined:
        icon = Icons.check_rounded;
        iconBg = colors.successLight;
        iconColor = colors.success;
        cardBg = colors.surface;
        isTintedCard = false;
        break;
      case NotificationType.waitTimeChanged:
        icon = Icons.update_rounded;
        iconBg = Color.alphaBlend(colors.textPrimary.withValues(alpha: 0.08), colors.surface);
        iconColor = colors.textSecondary;
        cardBg = colors.surface;
        isTintedCard = false;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isTintedCard
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: AppStyles.cardTitle(context)),
                const SizedBox(height: 4),
                Text(notification.message, style: AppStyles.bodyMuted(context)),
                const SizedBox(height: 6),
                Text(notification.timeLabel, style: AppStyles.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
