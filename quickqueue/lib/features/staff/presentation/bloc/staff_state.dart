import 'package:equatable/equatable.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {
  const StaffInitial();
}

class StaffLoading extends StaffState {
  const StaffLoading();
}

class QueueDashboardLoaded extends StaffState {
  final String currentTicket;
  final int totalWaiting;
  final int totalServed;
  final bool isPaused;
  final List<Map<String, dynamic>> queueList;

  const QueueDashboardLoaded({
    required this.currentTicket,
    required this.totalWaiting,
    required this.totalServed,
    required this.isPaused,
    required this.queueList,
  });

  @override
  List<Object?> get props => [
        currentTicket,
        totalWaiting,
        totalServed,
        isPaused,
        queueList,
      ];
}

class PatientServedSuccess extends StaffState {
  const PatientServedSuccess();
}

class PatientSkippedSuccess extends StaffState {
  const PatientSkippedSuccess();
}

class QueuePausedSuccess extends StaffState {
  const QueuePausedSuccess();
}

class QueueResumedSuccess extends StaffState {
  const QueueResumedSuccess();
}

class AnalyticsLoaded extends StaffState {
  final int totalServed;
  final int totalSkipped;
  final double avgWaitTime;
  final String peakHour;
  final Map<String, dynamic> hourlyData;

  const AnalyticsLoaded({
    required this.totalServed,
    required this.totalSkipped,
    required this.avgWaitTime,
    required this.peakHour,
    required this.hourlyData,
  });

  @override
  List<Object?> get props => [
        totalServed,
        totalSkipped,
        avgWaitTime,
        peakHour,
        hourlyData,
      ];
}

class StaffError extends StaffState {
  final String message;

  const StaffError({required this.message});

  @override
  List<Object?> get props => [message];
}