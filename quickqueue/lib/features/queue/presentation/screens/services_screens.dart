import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../../data/datasources/queue_remote_datasource.dart';
import '../../data/repositories/queue_repository_impl.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_queue_position.dart';
import '../../domain/usecases/get_queues.dart';
import '../../domain/usecases/join_queue.dart';
import '../../domain/usecases/leave_queue.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';
import 'my_ticket_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.location});

  final LocationEntity location;

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
        )..add(QueuesRequested(location.id));
      },
      child: _ServicesView(location: location),
    );
  }
}

class _ServicesView extends StatelessWidget {
  const _ServicesView({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<QueueBloc, QueueState>(
        listenWhen: (previous, current) => current.status == QueueStatus.joined && current.ticket != null,
        listener: (context, state) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MyTicketScreen(ticket: state.ticket!)),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Services', style: AppStyles.bodyMuted),
              ),
            ),
            QQHeader(title: location.name, subtitle: AppStrings.selectServiceSubtitle, compact: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(AppStrings.backToHome, style: AppStyles.link),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<QueueBloc, QueueState>(
                builder: (context, state) {
                  if (state.status == QueueStatus.loading || state.status == QueueStatus.initial) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (state.status == QueueStatus.error) {
                    return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    itemCount: state.queues.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final queue = state.queues[index];
                      final isSelected = state.selectedQueue?.id == queue.id;
                      return _QueueCard(
                        queue: queue,
                        isSelected: isSelected,
                        onTap: () => context.read<QueueBloc>().add(QueueSelected(queue)),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: BlocBuilder<QueueBloc, QueueState>(
                builder: (context, state) {
                  return QQButton(
                    label: AppStrings.joinSelectedQueue,
                    isLoading: state.status == QueueStatus.joining,
                    onPressed: state.selectedQueue == null
                        ? null
                        : () => context.read<QueueBloc>().add(
                              QueueJoinRequested(locationId: location.id, locationName: location.name),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.queue, required this.isSelected, required this.onTap});

  final QueueEntity queue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.4),
            boxShadow: isSelected
                ? null
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      queue.name,
                      style: AppStyles.cardTitle.copyWith(color: queue.isPriority ? AppColors.error : AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      queue.isPriority ? 'Priority queue' : '${queue.waitingCount} waiting',
                      style: AppStyles.bodyMuted.copyWith(
                        color: queue.isPriority ? AppColors.error : (isSelected ? AppColors.primary : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                queue.waitLabel,
                style: AppStyles.cardTitle.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
