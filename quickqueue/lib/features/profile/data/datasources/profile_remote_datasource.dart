import '../../domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileEntity> getProfile();

  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  });
}

/// In-memory stand-in for the Firestore-backed profile/history data.
/// Implements the same [ProfileRemoteDataSource] contract so it can be
/// swapped for a real implementation without touching the layers above it.
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  @override
  Future<ProfileEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const ProfileEntity(
      name: 'User',
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
  }

  @override
  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
