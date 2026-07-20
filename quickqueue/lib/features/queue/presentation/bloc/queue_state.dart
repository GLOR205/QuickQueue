import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/ticket_entity.dart';

enum QueueStatus { initial, loading, loaded, joining, joined, error }

class QueueState extends Equatable {
  const QueueState({
    this.status = QueueStatus.initial,
    this.queues = const [],
    this.selectedQueue,
    this.ticket,
    this.notifications = const [],
    this.errorMessage,
  });

  final QueueStatus status;
  final List<QueueEntity> queues;
  final QueueEntity? selectedQueue;
  final TicketEntity? ticket;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  QueueState copyWith({
    QueueStatus? status,
    List<QueueEntity>? queues,
    QueueEntity? selectedQueue,
    TicketEntity? ticket,
    List<NotificationEntity>? notifications,
  }) {
    return QueueState(
      status: status ?? this.status,
      queues: queues ?? this.queues,
      selectedQueue: selectedQueue ?? this.selectedQueue,
      ticket: ticket ?? this.ticket,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props =>
      [status, queues, selectedQueue, ticket, notifications, errorMessage];
}
