import '../entities/queue_entity.dart';
import '../entities/ticket_entity.dart';
import '../repositories/queue_repository.dart';

class JoinQueue {
  const JoinQueue(this._repository);

  final QueueRepository _repository;

  Future<TicketEntity> call({
    required String locationId,
    required String locationName,
    required QueueEntity queue,
  }) {
    return _repository.joinQueue(locationId: locationId, locationName: locationName, queue: queue);
  }
}
