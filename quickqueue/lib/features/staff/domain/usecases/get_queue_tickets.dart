import '../../../queue/domain/entities/ticket_entity.dart';
import '../repositories/staff_repository.dart';

class GetQueueTickets {
  const GetQueueTickets(this._repository);

  final StaffRepository _repository;

  Future<List<TicketEntity>> call(String queueId) => _repository.getQueueTickets(queueId);
}
