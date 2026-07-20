import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../location/presentation/screens/locations_screen.dart';
import '../../../profile/presentation/screens/rating_screen.dart';
import '../../../profile/presentation/screens/user_profile_screen.dart';
import '../../data/datasources/queue_remote_datasource.dart';
import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_queue_position.dart';
import '../../domain/usecases/get_queues.dart';
import '../../domain/usecases/join_queue.dart';
import '../../domain/usecases/leave_queue.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';
import 'notifications_screen.dart';

class MyTicketScreen extends StatelessWidget {
  const MyTicketScreen({super.key, required this.ticket});

  final TicketEntity ticket;

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
        )..add(TicketWatchStarted(ticket));
      },
      child: const _MyTicketView(),
    );
  }
}

class _MyTicketView extends StatelessWidget {
  const _MyTicketView();

  String _ordinal(int n) {
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

  void _switchTab(BuildContext context, QQNavTab tab) {
    if (tab == QQNavTab.ticket) return;
    if (tab == QQNavTab.alerts) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<QueueBloc, QueueState>(
        builder: (context, state) {
          final ticket = state.ticket;
          if (ticket == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final isServed = ticket.status == TicketStatus.served;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              QQHeader(
                title: AppStrings.yourTicket,
                subtitle: '${ticket.locationName} ${ticket.queueName}',
                compact: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(AppStrings.yourNumber,
                              style: AppStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            ticket.ticketNumber,
                            style: AppStyles.displayTitle.copyWith(fontSize: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(ticket.queueName, style: AppStyles.bodyMuted.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppStrings.positionInQueue, style: AppStyles.bodyMuted),
                              Text(
                                isServed ? 'Served' : _ordinal(ticket.positionInQueue),
                                style: AppStyles.cardTitle.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 34,
                            child: Row(
                              children: List.generate(ticket.totalInQueue, (i) {
                                final position = i + 1;
                                final isCurrent = !isServed && position == ticket.positionInQueue;
                                final isPast = isServed || position < ticket.positionInQueue;
                                return Expanded(
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: isCurrent
                                          ? AppColors.primary
                                          : (isPast ? AppColors.border : AppColors.primaryLight),
                                      child: Text(
                                        '$position',
                                        style: AppStyles.caption.copyWith(
                                          color: isCurrent ? Colors.white : AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatBox(label: 'Now serving', value: ticket.nowServingNumber)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatBox(label: 'Est. wait', value: '~${ticket.estimatedWaitMinutes}min')),
                        const SizedBox(width: 10),
                        Expanded(child: _StatBox(label: 'Counter', value: ticket.counterLabel)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!isServed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(ticket.positionInQueue - 1).clamp(0, 999)} people are in front of you, get ready',
                          style: AppStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 16),
                    isServed
                        ? QQButton(
                            label: AppStrings.rateExperience,
                            color: AppColors.success,
                            onPressed: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => RatingScreen(
                                  serviceName: ticket.queueName,
                                  roomLabel: 'Room - ${ticket.counterLabel}',
                                ),
                              ),
                            ),
                          )
                        : QQButton(
                            label: AppStrings.leaveQueue,
                            variant: QQButtonVariant.outlined,
                            onPressed: () {
                              context.read<QueueBloc>().add(const QueueLeaveRequested());
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LocationsScreen()),
                                (route) => false,
                              );
                            },
                          ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: QQBottomNav(
        current: QQNavTab.ticket,
        onTabSelected: (tab) => _switchTab(context, tab),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: AppStyles.cardTitle.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
