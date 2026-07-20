import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/submit_rating.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetUserProfile getUserProfile,
    required SubmitRating submitRating,
  })  : _getUserProfile = getUserProfile,
        _submitRating = submitRating,
        super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<RatingSubmitted>(_onRatingSubmitted);
  }

  final GetUserProfile _getUserProfile;
  final SubmitRating _submitRating;

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
}
