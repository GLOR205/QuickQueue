import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationsLoaded extends LocationState {
  final List<Map<String, dynamic>> locations;

  const LocationsLoaded({required this.locations});

  @override
  List<Object?> get props => [locations];
}

class LocationSelected extends LocationState {
  final Map<String, dynamic> location;

  const LocationSelected({required this.location});

  @override
  List<Object?> get props => [location];
}

class ServicesLoaded extends LocationState {
  final List<Map<String, dynamic>> services;
  final String locationName;

  const ServicesLoaded({
    required this.services,
    required this.locationName,
  });

  @override
  List<Object?> get props => [services, locationName];
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}