import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../profile/presentation/screens/user_profile_screen.dart';
import '../../data/datasources/queue_remote_datasource.dart';
import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_queue_position.dart';
import '../../domain/usecases/get_queues.dart';
import '../../domain/usecases/join_queue.dart';
import '../../domain/usecases/leave_queue.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = QueueRepositoryImpl(MockQueueRemoteDataSource());
        return QueueBloc(
          getQueues: GetQueues(repository),
          joinQueue: JoinQueue(repository),
          getQueuePosition: GetQueuePosition(repository),
          leaveQueue: LeaveQueue(repository),
          getNotifications: GetNotifications(repository),
        )..add(const NotificationsRequested());
      },
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  void _switchTab(BuildContext context, QQNavTab tab) {
    if (tab == QQNavTab.alerts) return;
    if (tab == QQNavTab.profile) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const QQHeader(
            title: AppStrings.notifications,
            subtitle: AppStrings.notificationsSubtitle,
          ),
          Expanded(
            child: BlocBuilder<QueueBloc, QueueState>(
              builder: (context, state) {
                if (state.status == QueueStatus.loading || state.status == QueueStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (state.notifications.isEmpty) {
                  return Center(child: Text('No notifications yet', style: AppStyles.bodyMuted));
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
      ),
      bottomNavigationBar: QQBottomNav(
        current: QQNavTab.alerts,
        onTabSelected: (tab) => _switchTab(context, tab),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconBg;
    final Color iconColor;
    final Color cardBg;

    switch (notification.type) {
      case NotificationType.positionUpdate:
        icon = Icons.priority_high_rounded;
        iconBg = AppColors.warning;
        iconColor = Colors.white;
        cardBg = AppColors.warningLight;
        break;
      case NotificationType.joined:
        icon = Icons.check_rounded;
        iconBg = AppColors.successLight;
        iconColor = AppColors.success;
        cardBg = AppColors.surface;
        break;
      case NotificationType.waitTimeChanged:
        icon = Icons.update_rounded;
        iconBg = const Color(0xFFE9EAEC);
        iconColor = AppColors.textSecondary;
        cardBg = AppColors.surface;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: cardBg == AppColors.surface
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
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
                Text(notification.title, style: AppStyles.cardTitle),
                const SizedBox(height: 4),
                Text(notification.message, style: AppStyles.bodyMuted),
                const SizedBox(height: 6),
                Text(notification.timeLabel, style: AppStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
