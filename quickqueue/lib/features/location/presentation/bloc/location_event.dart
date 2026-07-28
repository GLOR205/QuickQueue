import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocationsEvent extends LocationEvent {
  const LoadLocationsEvent();
}

class SearchLocationsEvent extends LocationEvent {
  final String query;

  const SearchLocationsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class SelectLocationEvent extends LocationEvent {
  final String locationId;

  const SelectLocationEvent({required this.locationId});

  @override
  List<Object?> get props => [locationId];
}

class LoadServicesEvent extends LocationEvent {
  final String locationId;

  const LoadServicesEvent({required this.locationId});

  @override
  List<Object?> get props => [locationId];
}