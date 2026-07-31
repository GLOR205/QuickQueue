import '../entities/staff_entity.dart';
import '../repositories/staff_repository.dart';

class SignInStaff {
  const SignInStaff(this._repository);

  final StaffRepository _repository;

  Future<StaffEntity> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
