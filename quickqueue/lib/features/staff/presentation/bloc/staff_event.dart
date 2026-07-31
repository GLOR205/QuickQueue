import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class LoadQueueDashboardEvent extends StaffEvent {
  final String queueId;

  const LoadQueueDashboardEvent({required this.queueId});

  @override
  List<Object?> get props => [queueId];
}

class MarkServedEvent extends StaffEvent {
  final String ticketId;
  final String queueId;

  const MarkServedEvent({
    required this.ticketId,
    required this.queueId,
  });

  @override
  List<Object?> get props => [ticketId, queueId];
}

class SkipPatientEvent extends StaffEvent {
  final String ticketId;
  final String queueId;
  final String reason;

  const SkipPatientEvent({
    required this.ticketId,
    required this.queueId,
    required this.reason,
  });

  @override
  List<Object?> get props => [ticketId, queueId, reason];
}

class PauseQueueEvent extends StaffEvent {
  final String queueId;
  final String reason;

  const PauseQueueEvent({
    required this.queueId,
    required this.reason,
  });

  @override
  List<Object?> get props => [queueId, reason];
}

class ResumeQueueEvent extends StaffEvent {
  final String queueId;

  const ResumeQueueEvent({required this.queueId});

  @override
  List<Object?> get props => [queueId];
}

class LoadAnalyticsEvent extends StaffEvent {
  final String locationId;
  final String serviceId;

  const LoadAnalyticsEvent({
    required this.locationId,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [locationId, serviceId];
}