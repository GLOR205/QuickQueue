import '../entities/staff_queue_option.dart';
import '../repositories/staff_repository.dart';

class GetStaffQueueOptions {
  const GetStaffQueueOptions(this._repository);

  final StaffRepository _repository;

  Future<List<StaffQueueOption>> call(String locationId) => _repository.getQueueOptions(locationId);
}
