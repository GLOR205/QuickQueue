import '../entities/ticket_entity.dart';
import '../repositories/queue_repository.dart';

/// Streams live position/ETA updates for an active ticket.
class GetQueuePosition {
  const GetQueuePosition(this._repository);

  final QueueRepository _repository;

  Stream<TicketEntity> call(String ticketNumber) => _repository.watchTicket(ticketNumber);
}
