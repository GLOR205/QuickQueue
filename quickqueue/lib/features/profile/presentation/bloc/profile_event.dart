import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfileEvent extends ProfileEvent {
  final String userId;

  const LoadUserProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateUserProfileEvent extends ProfileEvent {
  final String userId;
  final String fullName;
  final String photoUrl;

  const UpdateUserProfileEvent({
    required this.userId,
    required this.fullName,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, fullName, photoUrl];
}

class SubmitRatingEvent extends ProfileEvent {
  final String ticketId;
  final int rating;
  final String comment;

  const SubmitRatingEvent({
    required this.ticketId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [ticketId, rating, comment];
}