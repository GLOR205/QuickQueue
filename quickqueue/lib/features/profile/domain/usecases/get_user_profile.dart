import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile {
  const GetUserProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call() => _repository.getProfile();
}
