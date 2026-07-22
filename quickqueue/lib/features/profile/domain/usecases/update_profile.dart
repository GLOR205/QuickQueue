import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({required String name, required String phone, required String email}) {
    return _repository.updateProfile(name: name, phone: phone, email: email);
  }
}
