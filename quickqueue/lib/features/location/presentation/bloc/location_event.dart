import 'package:equatable/equatable.dart';

import '../../domain/entities/location_entity.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LocationsRequested extends LocationEvent {
  const LocationsRequested();
}

class LocationSearchChanged extends LocationEvent {
  const LocationSearchChanged(this.query);

  final String query;

class LoadLocationsEvent extends LocationEvent {
  const LoadLocationsEvent();
}

class SearchLocationsEvent extends LocationEvent {
  final String query;

  const SearchLocationsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class LocationSelected extends LocationEvent {
  const LocationSelected(this.location);

  final LocationEntity location;

  @override
  List<Object?> get props => [location];
}

class UseCurrentLocationRequested extends LocationEvent {
  const UseCurrentLocationRequested();
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
