import 'package:equatable/equatable.dart';

import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, submitting, submitted, error }

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
