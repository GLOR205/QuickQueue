import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/queue_remote_datasource.dart';

class QueueRepositoryImpl implements QueueRepository {
  const QueueRepositoryImpl(this._remoteDataSource);

  final QueueRemoteDataSource _remoteDataSource;

  @override
  Future<List<QueueEntity>> getQueues(String locationId) => _remoteDataSource.getQueues(locationId);

  @override
  Future<TicketEntity> joinQueue({
    required String locationId,
    required String locationName,
    required QueueEntity queue,
  }) {
    return _remoteDataSource.joinQueue(
      locationId: locationId,
      locationName: locationName,
      queue: queue,
    );
  }

  @override
  Stream<TicketEntity> watchTicket(String ticketNumber) => _remoteDataSource.watchTicket(ticketNumber);

  @override
  Future<void> leaveQueue(String ticketNumber) => _remoteDataSource.leaveQueue(ticketNumber);

  @override
  Future<List<NotificationEntity>> getNotifications() => _remoteDataSource.getNotifications();
}
