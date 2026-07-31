import 'package:equatable/equatable.dart';
feature/user-screens
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/coordinates.dart';
import '../../domain/entities/location_entity.dart';

enum LocationStatus { initial, loading, loaded, error }

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.locations = const [],
    this.query = '',
    this.selected,
    this.errorMessage,
    this.userPosition,
    this.locatingUser = false,
    this.locateErrorMessage,
  });

  final LocationStatus status;
  final List<LocationEntity> locations;
  final String query;
  final LocationEntity? selected;
  final String? errorMessage;

  /// Set once the user taps "Use my current location" and it resolves.
  final Coordinates? userPosition;

  /// True while resolving the device's current position.
  final bool locatingUser;

  /// Permission/service errors from the "use my location" action, shown
  /// separately from [errorMessage] since they shouldn't block the list.
  final String? locateErrorMessage;

  /// Search-filtered locations, sorted nearest-first once [userPosition] is
  /// known.
  List<LocationEntity> get filteredLocations {
    final q = query.trim().toLowerCase();
    final matches = q.isEmpty
        ? List<LocationEntity>.from(locations)
        : locations.where((location) => location.name.toLowerCase().contains(q)).toList();

    final position = userPosition;
    if (position != null) {
      matches.sort((a, b) => _distanceKm(position, a).compareTo(_distanceKm(position, b)));
    }
    return matches;
  }

  double? distanceKm(LocationEntity location) {
    final position = userPosition;
    if (position == null) return null;
    return _distanceKm(position, location);
  }

  static double _distanceKm(Coordinates from, LocationEntity to) {
    return Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude) /
        1000;
  }

  LocationState copyWith({
    LocationStatus? status,
    List<LocationEntity>? locations,
    String? query,
    LocationEntity? selected,
    Coordinates? userPosition,
    bool? locatingUser,
    String? locateErrorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      query: query ?? this.query,
      selected: selected ?? this.selected,
      userPosition: userPosition ?? this.userPosition,
      locatingUser: locatingUser ?? this.locatingUser,
      locateErrorMessage: locateErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        query,
        selected,
        errorMessage,
        userPosition,
        locatingUser,
        locateErrorMessage,
      ];
}


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
main
