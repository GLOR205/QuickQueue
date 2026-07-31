import '../repositories/staff_repository.dart';

class SkipPatient {
  const SkipPatient(this._repository);

  final StaffRepository _repository;

  Future<void> call(String ticketId) => _repository.skipTicket(ticketId);
}
