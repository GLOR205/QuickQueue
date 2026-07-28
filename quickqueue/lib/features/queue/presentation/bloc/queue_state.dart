import 'package:equatable/equatable.dart';

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