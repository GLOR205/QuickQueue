import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/submit_rating.dart';
import '../../domain/usecases/update_preferences.dart';
import '../../domain/usecases/update_profile.dart';
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
