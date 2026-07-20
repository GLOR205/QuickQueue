import 'package:equatable/equatable.dart';

import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/ticket_entity.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

class QueuesRequested extends QueueEvent {
  const QueuesRequested(this.locationId);

  final String locationId;

  @override
  List<Object?> get props => [locationId];
}

class QueueSelected extends QueueEvent {
  const QueueSelected(this.queue);

  final QueueEntity queue;

  @override
  List<Object?> get props => [queue];
}

class QueueJoinRequested extends QueueEvent {
  const QueueJoinRequested({required this.locationId, required this.locationName});

  final String locationId;
  final String locationName;

  @override
  List<Object?> get props => [locationId, locationName];
}

class TicketWatchStarted extends QueueEvent {
  const TicketWatchStarted(this.ticket);

  final TicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class TicketUpdated extends QueueEvent {
  const TicketUpdated(this.ticket);

  final TicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

class QueueLeaveRequested extends QueueEvent {
  const QueueLeaveRequested();
}

class NotificationsRequested extends QueueEvent {
  const NotificationsRequested();
}
