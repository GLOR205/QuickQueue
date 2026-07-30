import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickqueue/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickqueue/features/profile/presentation/bloc/profile_event.dart';
import 'package:quickqueue/features/profile/presentation/bloc/profile_state.dart';

// ProfileBloc requires a FirebaseAuth instance but never calls it in the
// handlers under test, so a bare unstubbed mock is enough here.
class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockFirebaseAuth firebaseAuth;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    firebaseAuth = _MockFirebaseAuth();
  });

  ProfileBloc buildBloc() =>
      ProfileBloc(firestore: firestore, firebaseAuth: firebaseAuth);

  group('LoadUserProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] with the user data and recent history',
      build: () {
        firestore.collection('users').doc('user1').set({
          'fullName': 'Jane Doe',
          'email': 'jane@example.com',
          'photoUrl': 'https://example.com/jane.png',
          'queuesJoined': 4,
          'avgWaitTime': 12,
          'timeSaved': 30,
        });
        firestore.collection('tickets').doc('t1').set({
          'userId': 'user1',
          'joinedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        });
        firestore.collection('tickets').doc('t2').set({
          'userId': 'user1',
          'joinedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
        });
        firestore.collection('tickets').doc('t3').set({
          'userId': 'someone-else',
          'joinedAt': Timestamp.fromDate(DateTime(2026, 1, 3)),
        });
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadUserProfileEvent(userId: 'user1')),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileLoaded>()
            .having((s) => s.fullName, 'fullName', 'Jane Doe')
            .having((s) => s.email, 'email', 'jane@example.com')
            .having((s) => s.queuesJoined, 'queuesJoined', 4)
            .having((s) => s.avgWaitTime, 'avgWaitTime', 12)
            .having((s) => s.timeSaved, 'timeSaved', 30)
            .having((s) => s.recentHistory.length, 'recentHistory.length', 2),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when the user does not exist',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const LoadUserProfileEvent(userId: 'missing-user')),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'User not found'),
      ],
    );
  });

  group('UpdateUserProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileUpdated] and persists the new fields',
      build: () {
        firestore.collection('users').doc('user1').set({
          'fullName': 'Old Name',
          'photoUrl': 'old.png',
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const UpdateUserProfileEvent(
        userId: 'user1',
        fullName: 'New Name',
        photoUrl: 'new.png',
      )),
      expect: () => [
        const ProfileLoading(),
        const ProfileUpdated(),
      ],
      verify: (_) async {
        final doc = await firestore.collection('users').doc('user1').get();
        expect(doc.data()!['fullName'], 'New Name');
        expect(doc.data()!['photoUrl'], 'new.png');
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when the user document does not exist',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateUserProfileEvent(
        userId: 'missing-user',
        fullName: 'New Name',
        photoUrl: 'new.png',
      )),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileError>(),
      ],
    );
  });

  group('SubmitRatingEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, RatingSubmitted] and persists the rating',
      build: () {
        firestore.collection('tickets').doc('ticket1').set({
          'status': 'served',
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubmitRatingEvent(
        ticketId: 'ticket1',
        rating: 5,
        comment: 'Great service',
      )),
      expect: () => [
        const ProfileLoading(),
        const RatingSubmitted(),
      ],
      verify: (_) async {
        final doc =
            await firestore.collection('tickets').doc('ticket1').get();
        expect(doc.data()!['rating'], 5);
        expect(doc.data()!['ratingComment'], 'Great service');
      },
    );
  });
}
