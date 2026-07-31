import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

/// Reads the signed-in user's profile from Firebase Auth (name, email), the
/// Firestore `users` doc (phone, preferences), and the `tickets` collection
/// (queue history and stats) written by [FirebaseQueueRemoteDataSource] when
/// a queue is joined.
class FirebaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  FirebaseProfileRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<ProfileEntity> getProfile() async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    final data = uid == null ? null : (await _firestore.collection('users').doc(uid).get()).data();

    var queuesJoined = 0;
    var avgWaitMinutes = 0;
    var history = const <ProfileHistoryEntry>[];

    if (uid != null) {
      final ticketDocs = (await _firestore.collection('tickets').where('userId', isEqualTo: uid).get())
          .docs
          .toList()
        ..sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

      queuesJoined = ticketDocs.length;
      if (ticketDocs.isNotEmpty) {
        final totalWait = ticketDocs.fold<int>(
          0,
          (total, doc) => total + ((doc.data()['estimatedWaitMinutes'] as num?)?.toInt() ?? 0),
        );
        avgWaitMinutes = (totalWait / ticketDocs.length).round();
      }

      history = ticketDocs
          .where((doc) => doc.data()['status'] == 'served')
          .take(10)
          .map((doc) {
            final ticketData = doc.data();
            return ProfileHistoryEntry(
              locationName: (ticketData['locationName'] as String?) ?? '',
              serviceName: (ticketData['queueName'] as String?) ?? '',
              dateLabel: _dateLabel(ticketData['createdAt'] as Timestamp?),
              colorValue: (ticketData['colorValue'] as num?)?.toInt() ?? 0xFF2B7A78,
              avatarLetter: (ticketData['avatarLetter'] as String?) ?? 'H',
            );
          })
          .toList();
    }

    return ProfileEntity(
      name: user?.displayName ?? (data?['name'] as String?) ?? 'User',
      email: user?.email ?? (data?['email'] as String?) ?? '',
      phone: (data?['phone'] as String?) ?? '',
      queuesJoined: queuesJoined,
      avgWaitMinutes: avgWaitMinutes,
      timeSavedHours: 0,
      history: history,
      notificationsEnabled: (data?['notificationsEnabled'] as bool?) ?? true,
      languageCode: (data?['languageCode'] as String?) ?? 'en',
    );
  }

  String _dateLabel(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  }) async {}

  @override
  Future<ProfileEntity> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'phone': phone,
        'email': email,
      }, SetOptions(merge: true));
    }
    return getProfile();
  }

  @override
  Future<void> changePassword({required String newPassword}) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  @override
  Future<ProfileEntity> updatePreferences({
    required bool notificationsEnabled,
    required String languageCode,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).set({
        'notificationsEnabled': notificationsEnabled,
        'languageCode': languageCode,
      }, SetOptions(merge: true));
    }
    return getProfile();
  }
}
