import '../../../queue/domain/entities/ticket_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/staff_queue_option.dart';
import '../../domain/entities/staff_ticket_record.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_datasource.dart';

class StaffRepositoryImpl implements StaffRepository {
  const StaffRepositoryImpl(this._remoteDataSource);

  final StaffRemoteDataSource _remoteDataSource;

  @override
  Future<StaffEntity> signIn({required String email, required String password}) {
    return _remoteDataSource.signIn(email: email, password: password);
  }

  @override
  Future<StaffEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String locationId,
    required String locationName,
    required String queueId,
    required String counterLabel,
  }) {
    return _remoteDataSource.signUp(
      name: name,
      email: email,
      password: password,
      locationId: locationId,
      locationName: locationName,
      queueId: queueId,
      counterLabel: counterLabel,
    );
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Future<List<StaffQueueOption>> getQueueOptions(String locationId) =>
      _remoteDataSource.getQueueOptions(locationId);

  @override
  Future<List<TicketEntity>> getQueueTickets(String queueId) => _remoteDataSource.getQueueTickets(queueId);

  @override
  Future<List<StaffTicketRecord>> getQueueTicketHistory(String queueId) =>
      _remoteDataSource.getQueueTicketHistory(queueId);

  @override
  Future<void> markServed(String ticketId) => _remoteDataSource.markServed(ticketId);

  @override
  Future<void> skipTicket(String ticketId) => _remoteDataSource.skipTicket(ticketId);
}
