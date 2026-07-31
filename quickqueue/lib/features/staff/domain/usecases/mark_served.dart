import '../repositories/staff_repository.dart';

class MarkServed {
  const MarkServed(this._repository);

  final StaffRepository _repository;

  Future<void> call(String ticketId) => _repository.markServed(ticketId);
}
