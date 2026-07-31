import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  });

  Future<ProfileEntity> updateProfile({
    required String name,
    required String phone,
    required String email,
  });

  Future<void> changePassword({required String newPassword});

  Future<ProfileEntity> updatePreferences({
    required bool notificationsEnabled,
    required String languageCode,
  });
}
