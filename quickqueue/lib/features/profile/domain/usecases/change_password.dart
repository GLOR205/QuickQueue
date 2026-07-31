import '../repositories/profile_repository.dart';

class ChangePassword {
  const ChangePassword(this._repository);

  final ProfileRepository _repository;

  Future<void> call({required String newPassword}) {
    return _repository.changePassword(newPassword: newPassword);
  }
}
