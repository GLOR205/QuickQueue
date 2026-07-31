import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_position.dart';
import '../../domain/usecases/get_locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final FirebaseFirestore firestore;

  LocationBloc({required this.firestore}) : super(const LocationInitial()) {
    on<LoadLocationsEvent>(_onLoadLocations);
    on<SearchLocationsEvent>(_onSearchLocations);
    on<SelectLocationEvent>(_onSelectLocation);
    on<LoadServicesEvent>(_onLoadServices);
  }

  Future<void> _onLoadLocations(
    LoadLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final snapshot = await firestore
          .collection('locations')
          .where('isOpen', isEqualTo: true)
          .get();

      final locations = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      emit(LocationsLoaded(locations: locations));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  Future<void> _onSearchLocations(
    SearchLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final snapshot = await firestore
          .collection('locations')
          .get();

      final allLocations = snapshot.docs
          .map((doc) => doc.data())
          .toList();

      final filtered = allLocations.where((location) {
        final name = location['name'] as String? ?? '';
        return name
            .toLowerCase()
            .contains(event.query.toLowerCase());
      }).toList();

      emit(LocationsLoaded(locations: filtered));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  Future<void> _onSelectLocation(
    SelectLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final doc = await firestore
          .collection('locations')
          .doc(event.locationId)
          .get();

      if (!doc.exists) {
        emit(const LocationError(message: 'Location not found'));
        return;
      }

      emit(LocationSelected(location: doc.data()!));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  Future<void> _onLoadServices(
    LoadServicesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final locationDoc = await firestore
          .collection('locations')
          .doc(event.locationId)
          .get();

      final locationName =
          locationDoc.data()?['name'] as String? ?? '';

      final servicesSnapshot = await firestore
          .collection('services')
          .where('locationId', isEqualTo: event.locationId)
          .where('isActive', isEqualTo: true)
          .get();

      final services = servicesSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      emit(ServicesLoaded(
        services: services,
        locationName: locationName,
      ));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }
}
