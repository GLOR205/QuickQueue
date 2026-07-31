import '../entities/staff_ticket_record.dart';
import '../repositories/staff_repository.dart';

class GetQueueTicketHistory {
  const GetQueueTicketHistory(this._repository);

  final StaffRepository _repository;

  Future<List<StaffTicketRecord>> call(String queueId) => _repository.getQueueTicketHistory(queueId);
}
