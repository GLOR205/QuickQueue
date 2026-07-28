import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
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