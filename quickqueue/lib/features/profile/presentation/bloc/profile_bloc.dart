import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProfileBloc({
    required this.firestore,
    required this.firebaseAuth,
  }) : super(const ProfileInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<SubmitRatingEvent>(_onSubmitRating);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final userDoc = await firestore
          .collection('users')
          .doc(event.userId)
          .get();

      if (!userDoc.exists) {
        emit(const ProfileError(message: 'User not found'));
        return;
      }

      final data = userDoc.data()!;

      final historySnapshot = await firestore
          .collection('tickets')
          .where('userId', isEqualTo: event.userId)
          .orderBy('joinedAt', descending: true)
          .limit(5)
          .get();

      final recentHistory = historySnapshot.docs
          .map((doc) => doc.data())
          .toList();

      emit(ProfileLoaded(
        fullName: data['fullName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        photoUrl: data['photoUrl'] as String? ?? '',
        queuesJoined: data['queuesJoined'] as int? ?? 0,
        avgWaitTime: data['avgWaitTime'] as int? ?? 0,
        timeSaved: data['timeSaved'] as int? ?? 0,
        recentHistory: recentHistory,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await firestore
          .collection('users')
          .doc(event.userId)
          .update({
        'fullName': event.fullName,
        'photoUrl': event.photoUrl,
      });

      emit(const ProfileUpdated());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onSubmitRating(
    SubmitRatingEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await firestore
          .collection('tickets')
          .doc(event.ticketId)
          .update({
        'rating': event.rating,
        'ratingComment': event.comment,
      });

      emit(const RatingSubmitted());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}