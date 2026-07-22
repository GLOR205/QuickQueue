import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdatePreferences {
  const UpdatePreferences(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({required bool notificationsEnabled, required String languageCode}) {
    return _repository.updatePreferences(
      notificationsEnabled: notificationsEnabled,
      languageCode: languageCode,
    );
  }
}
