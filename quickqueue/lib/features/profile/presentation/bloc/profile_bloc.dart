import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/submit_rating.dart';
import '../../domain/usecases/update_preferences.dart';
import '../../domain/usecases/update_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetUserProfile getUserProfile,
    required SubmitRating submitRating,
    required UpdateProfile updateProfile,
    required ChangePassword changePassword,
    required UpdatePreferences updatePreferences,
  })  : _getUserProfile = getUserProfile,
        _submitRating = submitRating,
        _updateProfile = updateProfile,
        _changePassword = changePassword,
        _updatePreferences = updatePreferences,
        super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<RatingSubmitted>(_onRatingSubmitted);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<PasswordChangeRequested>(_onPasswordChangeRequested);
    on<PreferencesUpdateRequested>(_onPreferencesUpdateRequested);
  }

  final GetUserProfile _getUserProfile;
  final SubmitRating _submitRating;
  final UpdateProfile _updateProfile;
  final ChangePassword _changePassword;
  final UpdatePreferences _updatePreferences;

  Future<void> _onRequested(ProfileRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _getUserProfile();
      emit(ProfileState(status: ProfileStatus.loaded, profile: profile));
    } on AppException catch (e) {
      emit(ProfileState(status: ProfileStatus.error, errorMessage: e.message));
    }
  }

  Future<void> _onRatingSubmitted(RatingSubmitted event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.submitting));
    try {
      await _submitRating(stars: event.stars, comment: event.comment, serviceName: event.serviceName);
      emit(state.copyWith(status: ProfileStatus.submitted));
    } on AppException catch (e) {
      emit(ProfileState(status: ProfileStatus.error, errorMessage: e.message, profile: state.profile));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      final profile = await _updateProfile(name: event.name, phone: event.phone, email: event.email);
      emit(ProfileState(status: ProfileStatus.updated, profile: profile));
    } on AppException catch (e) {
      emit(ProfileState(status: ProfileStatus.error, errorMessage: e.message, profile: state.profile));
    }
  }

  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      await _changePassword(newPassword: event.newPassword);
      emit(state.copyWith(status: ProfileStatus.updated));
    } on AppException catch (e) {
      emit(ProfileState(status: ProfileStatus.error, errorMessage: e.message, profile: state.profile));
    }
  }

  Future<void> _onPreferencesUpdateRequested(
    PreferencesUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final profile = await _updatePreferences(
        notificationsEnabled: event.notificationsEnabled,
        languageCode: event.languageCode,
      );
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } on AppException catch (e) {
      emit(ProfileState(status: ProfileStatus.error, errorMessage: e.message, profile: state.profile));
    }
  }
}
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
