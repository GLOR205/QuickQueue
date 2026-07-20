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

  @override
  List<Object?> get props => [query];
}

class LocationSelected extends LocationEvent {
  const LocationSelected(this.location);

  final LocationEntity location;

  @override
  List<Object?> get props => [location];
}
