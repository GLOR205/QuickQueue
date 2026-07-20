import 'package:equatable/equatable.dart';

import '../../domain/entities/location_entity.dart';

enum LocationStatus { initial, loading, loaded, error }

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.locations = const [],
    this.query = '',
    this.selected,
    this.errorMessage,
  });

  final LocationStatus status;
  final List<LocationEntity> locations;
  final String query;
  final LocationEntity? selected;
  final String? errorMessage;

  List<LocationEntity> get filteredLocations {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return locations;
    return locations.where((location) => location.name.toLowerCase().contains(q)).toList();
  }

  LocationState copyWith({
    LocationStatus? status,
    List<LocationEntity>? locations,
    String? query,
    LocationEntity? selected,
  }) {
    return LocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      query: query ?? this.query,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [status, locations, query, selected, errorMessage];
}
