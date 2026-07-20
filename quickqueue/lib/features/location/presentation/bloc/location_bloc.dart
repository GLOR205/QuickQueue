import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_locations.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({required GetLocations getLocations})
      : _getLocations = getLocations,
        super(const LocationState()) {
    on<LocationsRequested>(_onRequested);
    on<LocationSearchChanged>(_onSearchChanged);
    on<LocationSelected>(_onSelected);
  }

  final GetLocations _getLocations;

  Future<void> _onRequested(LocationsRequested event, Emitter<LocationState> emit) async {
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final locations = await _getLocations();
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
}
