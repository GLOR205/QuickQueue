import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../location/presentation/screens/location_categories_screen.dart';
import '../../../profile/presentation/screens/rating_screen.dart';
import '../../domain/entities/ticket_entity.dart';
import '../bloc/queue_bloc.dart';
import '../bloc/queue_event.dart';
import '../bloc/queue_state.dart';

/// The Ticket tab body inside [HomeShell]. Reads the session-scoped
/// [QueueBloc] provided at the app root, so it shows whatever ticket is
/// currently active (or an empty state if none) regardless of which other
/// tab or screen the user was on before.
class MyTicketBody extends StatelessWidget {
  const MyTicketBody({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        final ticket = state.ticket;
        if (ticket == null) {
          return const _EmptyTicketState();
        }
        final colors = context.colors;
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
                      color: colors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(AppStrings.yourNumber,
                            style: AppStyles.caption(context).copyWith(color: colors.primary, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          ticket.ticketNumber,
                          style: AppStyles.displayTitle(context).copyWith(fontSize: 40, color: colors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(ticket.queueName, style: AppStyles.bodyMuted(context).copyWith(color: colors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
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
                            Text(AppStrings.positionInQueue, style: AppStyles.bodyMuted(context)),
                            Text(
                              isServed ? 'Served' : _ordinal(ticket.positionInQueue),
                              style: AppStyles.cardTitle(context).copyWith(color: colors.primary),
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
                                        ? colors.primary
                                        : (isPast ? colors.border : colors.primaryLight),
                                    child: Text(
                                      '$position',
                                      style: AppStyles.caption(context).copyWith(
                                        color: isCurrent ? Colors.white : colors.textSecondary,
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
                        color: colors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(ticket.positionInQueue - 1).clamp(0, 999)} people are in front of you, get ready',
                        style: AppStyles.body(context).copyWith(color: colors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 16),
                  isServed
                      ? QQButton(
                          label: AppStrings.rateExperience,
                          color: colors.success,
                          onPressed: () => Navigator.of(context).push(
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
                          onPressed: () => context.read<QueueBloc>().add(const QueueLeaveRequested()),
                        ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyTicketState extends StatelessWidget {
  const _EmptyTicketState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 56, color: colors.textMuted),
            const SizedBox(height: 16),
            Text('No active ticket', style: AppStyles.sectionTitle(context)),
            const SizedBox(height: 8),
            Text(
              "You haven't joined a queue yet. Find a nearby location to get started.",
              textAlign: TextAlign.center,
              style: AppStyles.bodyMuted(context),
            ),
            const SizedBox(height: 20),
            QQButton(
              label: 'Find a queue',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocationCategoriesScreen()),
              ),
            ),
          ],
        ),
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
    final colors = context.colors;
    final chipColor = Color.alphaBlend(colors.textPrimary.withValues(alpha: 0.06), colors.surface);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: AppStyles.cardTitle(context).copyWith(color: colors.primary)),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.caption(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
