import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class SignUpStaff {
  const SignUpStaff(this._repository);

  final StaffRepository _repository;

  Future<StaffEntity> call({
    required String name,
    required String email,
    required String password,
    required String locationId,
    required String locationName,
    required String queueId,
    required String counterLabel,
  }) {
    return _repository.signUp(
      name: name,
      email: email,
      password: password,
      locationId: locationId,
      locationName: locationName,
      queueId: queueId,
      counterLabel: counterLabel,
    );
  }
}
