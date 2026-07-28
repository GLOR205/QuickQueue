import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_position.dart';
import '../../domain/usecases/get_locations.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({
    required GetLocations getLocations,
    required GetCurrentPosition getCurrentPosition,
    required LocationCategory category,
  })  : _getLocations = getLocations,
        _getCurrentPosition = getCurrentPosition,
        _category = category,
        super(const LocationState()) {
    on<LocationsRequested>(_onRequested);
    on<LocationSearchChanged>(_onSearchChanged);
    on<LocationSelected>(_onSelected);
    on<UseCurrentLocationRequested>(_onUseCurrentLocationRequested);
  }

  final GetLocations _getLocations;
  final GetCurrentPosition _getCurrentPosition;
  final LocationCategory _category;

  Future<void> _onRequested(LocationsRequested event, Emitter<LocationState> emit) async {
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final all = await _getLocations();
      final locations = all.where((location) => location.category == _category).toList();
      emit(LocationState(
        status: LocationStatus.loaded,
        locations: locations,
        selected: locations.isNotEmpty ? locations.first : null,
      ));
    } on AppException catch (e) {
      emit(LocationState(status: LocationStatus.error, errorMessage: e.message));
    }
  }

  void _onSearchChanged(LocationSearchChanged event, Emitter<LocationState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onSelected(LocationSelected event, Emitter<LocationState> emit) {
    emit(state.copyWith(selected: event.location));
  }

  Future<void> _onUseCurrentLocationRequested(
    UseCurrentLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(locatingUser: true, locateErrorMessage: null));
    try {
      final position = await _getCurrentPosition();
      emit(state.copyWith(userPosition: position, locatingUser: false, locateErrorMessage: null));
    } on AppException catch (e) {
      emit(state.copyWith(locatingUser: false, locateErrorMessage: e.message));
    }
  }
}
