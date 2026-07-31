import 'package:equatable/equatable.dart';

enum TicketStatus { waiting, almostReady, served }

class TicketEntity extends Equatable {
  const TicketEntity({
    required this.ticketNumber,
    required this.queueName,
    required this.locationName,
    required this.positionInQueue,
    required this.totalInQueue,
    required this.nowServingNumber,
    required this.estimatedWaitMinutes,
    required this.counterLabel,
    this.status = TicketStatus.waiting,
  });

  final String ticketNumber;
  final String queueName;
  final String locationName;
  final int positionInQueue;
  final int totalInQueue;
  final String nowServingNumber;
  final int estimatedWaitMinutes;
  final String counterLabel;
  final TicketStatus status;

  TicketEntity copyWith({
    int? positionInQueue,
    int? estimatedWaitMinutes,
    TicketStatus? status,
  }) {
    return TicketEntity(
      ticketNumber: ticketNumber,
      queueName: queueName,
      locationName: locationName,
      positionInQueue: positionInQueue ?? this.positionInQueue,
      totalInQueue: totalInQueue,
      nowServingNumber: nowServingNumber,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      counterLabel: counterLabel,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        ticketNumber,
        queueName,
        locationName,
        positionInQueue,
        totalInQueue,
        nowServingNumber,
        estimatedWaitMinutes,
        counterLabel,
        status,
      ];
}
