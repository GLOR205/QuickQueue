import '../entities/notification_entity.dart';
import '../repositories/queue_repository.dart';

class GetNotifications {
  const GetNotifications(this._repository);

  final QueueRepository _repository;

  Future<List<NotificationEntity>> call() => _repository.getNotifications();
}
