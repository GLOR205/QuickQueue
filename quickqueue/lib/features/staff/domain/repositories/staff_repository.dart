import '../../../queue/domain/entities/ticket_entity.dart';
import '../entities/staff_entity.dart';
import '../entities/staff_queue_option.dart';
import '../entities/staff_ticket_record.dart';

abstract class StaffRepository {
  Future<StaffEntity> signIn({required String email, required String password});

  Future<StaffEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String locationId,
    required String locationName,
    required String queueId,
    required String counterLabel,
  });

  Future<void> signOut();

  Future<List<StaffQueueOption>> getQueueOptions(String locationId);

  Future<List<TicketEntity>> getQueueTickets(String queueId);

  /// All tickets ever created for this queue (any status), for
  /// analytics/alerts — unlike [getQueueTickets], not filtered to active ones.
  Future<List<StaffTicketRecord>> getQueueTicketHistory(String queueId);

  Future<void> markServed(String ticketId);

  Future<void> skipTicket(String ticketId);
}
