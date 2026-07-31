import 'package:equatable/equatable.dart';

feature/user-screens
import '../../domain/entities/profile_entity.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  updating,
  updated,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({this.status = ProfileStatus.initial, this.profile, this.errorMessage});

  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  ProfileState copyWith({ProfileStatus? status, ProfileEntity? profile}) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final String fullName;
  final String email;
  final String photoUrl;
  final int queuesJoined;
  final int avgWaitTime;
  final int timeSaved;
  final List<Map<String, dynamic>> recentHistory;

  const ProfileLoaded({
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.queuesJoined,
    required this.avgWaitTime,
    required this.timeSaved,
    required this.recentHistory,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        photoUrl,
        queuesJoined,
        avgWaitTime,
        timeSaved,
        recentHistory,
      ];
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated();
}

class RatingSubmitted extends ProfileState {
  const RatingSubmitted();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
main
