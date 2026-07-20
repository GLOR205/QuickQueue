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
