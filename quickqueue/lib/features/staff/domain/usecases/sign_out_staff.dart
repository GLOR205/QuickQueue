import '../repositories/staff_repository.dart';

class SignOutStaff {
  const SignOutStaff(this._repository);

  final StaffRepository _repository;

  Future<void> call() => _repository.signOut();
}
