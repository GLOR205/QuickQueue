import 'package:equatable/equatable.dart';

feature/user-screens
import '../../domain/entities/location_entity.dart';

main
import '../../domain/entities/location_entity.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

feature/user-screens
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

main
  @override
  List<Object?> get props => [query];
}

feature/user-screens
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
main
