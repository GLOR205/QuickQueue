import 'package:equatable/equatable.dart';

feature/user-screens
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
    String? errorMessage,
  }) {
    return QueueState(
      status: status ?? this.status,
      queues: queues ?? this.queues,
      selectedQueue: selectedQueue ?? this.selectedQueue,
      ticket: ticket ?? this.ticket,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }

  /// Clears the active ticket while preserving everything else — copyWith
  /// can't null out [ticket] since its `??` pattern treats null as "leave
  /// unchanged".
  QueueState clearTicket() {
    return QueueState(
      status: status,
      queues: queues,
      selectedQueue: selectedQueue,
      notifications: notifications,
    );
  }

  @override
  List<Object?> get props =>
      [status, queues, selectedQueue, ticket, notifications, errorMessage];
}

abstract class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {
  const QueueInitial();
}

class QueueLoading extends QueueState {
  const QueueLoading();
}

class QueueJoined extends QueueState {
  final String ticketId;
  final String ticketNumber;
  final int position;
  final int estimatedWait;
  final String queueId;

  const QueueJoined({
    required this.ticketId,
    required this.ticketNumber,
    required this.position,
    required this.estimatedWait,
    required this.queueId,
  });

  @override
  List<Object?> get props => [
        ticketId,
        ticketNumber,
        position,
        estimatedWait,
        queueId,
      ];
}

class QueueUpdated extends QueueState {
  final String ticketNumber;
  final int position;
  final int estimatedWait;
  final String currentNumber;
  final String counter;

  const QueueUpdated({
    required this.ticketNumber,
    required this.position,
    required this.estimatedWait,
    required this.currentNumber,
    required this.counter,
  });

  @override
  List<Object?> get props => [
        ticketNumber,
        position,
        estimatedWait,
        currentNumber,
        counter,
      ];
}

class QueueLeft extends QueueState {
  const QueueLeft();
}

class QueueError extends QueueState {
  final String message;

  const QueueError({required this.message});

  @override
  List<Object?> get props => [message];
}

class QueueServed extends QueueState {
  final String ticketNumber;
  final int timeSaved;

  const QueueServed({
    required this.ticketNumber,
    required this.timeSaved,
  });

  @override
  List<Object?> get props => [ticketNumber, timeSaved];
}
main
