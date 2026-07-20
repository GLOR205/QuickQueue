import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  });
}
