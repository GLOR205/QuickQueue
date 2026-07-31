import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/navigation/nav_tab_cubit.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../../domain/entities/queue_entity.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, required this.location});

  final LocationEntity location;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QueueBloc>().add(QueuesRequested(widget.location.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: BlocListener<QueueBloc, QueueState>(
        listenWhen: (previous, current) => current.status == QueueStatus.joined && current.ticket != null,
        listener: (context, state) {
          context.read<NavTabCubit>().select(QQNavTab.ticket);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Services', style: AppStyles.bodyMuted(context)),
              ),
            ),
            QQHeader(title: widget.location.name, subtitle: AppStrings.selectServiceSubtitle, compact: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
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
              child: BlocBuilder<QueueBloc, QueueState>(
                builder: (context, state) {
                  if (state.status == QueueStatus.loading || state.status == QueueStatus.initial) {
                    return Center(child: CircularProgressIndicator(color: colors.primary));
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
                              QueueJoinRequested(locationId: widget.location.id, locationName: widget.location.name),
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
    final colors = context.colors;
    return Material(
      color: isSelected ? colors.primaryLight : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? colors.primary : Colors.transparent, width: 1.4),
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
                      style: AppStyles.cardTitle(context).copyWith(color: queue.isPriority ? colors.error : colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      queue.isPriority ? 'Priority queue' : '${queue.waitingCount} waiting',
                      style: AppStyles.bodyMuted(context).copyWith(
                        color: queue.isPriority ? colors.error : (isSelected ? colors.primary : colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                queue.waitLabel,
                style: AppStyles.cardTitle(context).copyWith(
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
