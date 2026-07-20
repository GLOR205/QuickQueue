import '../repositories/queue_repository.dart';

class LeaveQueue {
  const LeaveQueue(this._repository);

  final QueueRepository _repository;

  Future<void> call(String ticketNumber) => _repository.leaveQueue(ticketNumber);
}
