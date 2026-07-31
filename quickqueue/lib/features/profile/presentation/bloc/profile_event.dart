import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class RatingSubmitted extends ProfileEvent {
  const RatingSubmitted({required this.stars, required this.comment, required this.serviceName});

  final int stars;
  final String comment;
  final String serviceName;

  @override
  List<Object?> get props => [stars, comment, serviceName];
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({required this.name, required this.phone, required this.email});

  final String name;
  final String phone;
  final String email;

  @override
  List<Object?> get props => [name, phone, email];
}

class PasswordChangeRequested extends ProfileEvent {
  const PasswordChangeRequested({required this.newPassword});

  final String newPassword;

  @override
  List<Object?> get props => [newPassword];
}

class PreferencesUpdateRequested extends ProfileEvent {
  const PreferencesUpdateRequested({required this.notificationsEnabled, required this.languageCode});

  final bool notificationsEnabled;
  final String languageCode;

  @override
  List<Object?> get props => [notificationsEnabled, languageCode];
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
