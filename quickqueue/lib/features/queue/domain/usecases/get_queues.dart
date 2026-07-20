import '../entities/queue_entity.dart';
import '../repositories/queue_repository.dart';

class GetQueues {
  const GetQueues(this._repository);

  final QueueRepository _repository;

  Future<List<QueueEntity>> call(String locationId) => _repository.getQueues(locationId);
}
