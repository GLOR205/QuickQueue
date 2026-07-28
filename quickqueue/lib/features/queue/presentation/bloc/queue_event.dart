import 'package:equatable/equatable.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object?> get props => [];
}

class JoinQueueEvent extends QueueEvent {
  final String serviceId;
  final String locationId;
  final String userId;

  const JoinQueueEvent({
    required this.serviceId,
    required this.locationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [serviceId, locationId, userId];
}

class LeaveQueueEvent extends QueueEvent {
  final String ticketId;
  final String queueId;

  const LeaveQueueEvent({
    required this.ticketId,
    required this.queueId,
  });

  @override
  List<Object?> get props => [ticketId, queueId];
}

class GetQueuePositionEvent extends QueueEvent {
  final String ticketId;

  const GetQueuePositionEvent({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

class LoadQueueEvent extends QueueEvent {
  final String queueId;

  const LoadQueueEvent({required this.queueId});

  @override
  List<Object?> get props => [queueId];
}

class QueueUpdatedEvent extends QueueEvent {
  final Map<String, dynamic> queueData;

  const QueueUpdatedEvent({required this.queueData});

  @override
  List<Object?> get props => [queueData];
}