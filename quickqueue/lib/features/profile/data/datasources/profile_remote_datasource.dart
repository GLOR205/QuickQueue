import '../../domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
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

/// In-memory stand-in for the Firestore-backed profile/history data.
/// Implements the same [ProfileRemoteDataSource] contract so it can be
/// swapped for a real implementation without touching the layers above it.
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  ProfileEntity _profile = const ProfileEntity(
    name: 'User',
    email: 'user@quickqueue.dev',
    phone: '+250 788 000 000',
    queuesJoined: 14,
    avgWaitMinutes: 22,
    timeSavedHours: 4.2,
    history: [
      ProfileHistoryEntry(
        locationName: 'King Faisal',
        serviceName: 'consultation',
        dateLabel: 'Today',
        colorValue: 0xFF2B7A78,
        avatarLetter: 'H',
      ),
      ProfileHistoryEntry(
        locationName: 'Bank of Kigali',
        serviceName: 'Teller',
        dateLabel: 'May 28',
        colorValue: 0xFF6C63B5,
        avatarLetter: 'B',
      ),
      ProfileHistoryEntry(
        locationName: 'CHUK',
        serviceName: 'consultation',
        dateLabel: 'May 25',
        colorValue: 0xFF3E8E5A,
        avatarLetter: 'H',
      ),
    ],
  );

  @override
  Future<ProfileEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _profile;
  }

  @override
  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _profile = _profile.copyWith(name: name, phone: phone, email: email);
    return _profile;
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<ProfileEntity> updatePreferences({
    required bool notificationsEnabled,
    required String languageCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = _profile.copyWith(notificationsEnabled: notificationsEnabled, languageCode: languageCode);
    return _profile;
  }
}
