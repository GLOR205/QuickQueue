import '../entities/notification_entity.dart';
import '../entities/queue_entity.dart';
import '../entities/ticket_entity.dart';

abstract class QueueRepository {
  Future<List<QueueEntity>> getQueues(String locationId);

  Future<TicketEntity> joinQueue({
    required String locationId,
    required String locationName,
    required QueueEntity queue,
  });

  Stream<TicketEntity> watchTicket(String ticketNumber);

  Future<void> leaveQueue(String ticketNumber);

  Future<List<NotificationEntity>> getNotifications();
}
