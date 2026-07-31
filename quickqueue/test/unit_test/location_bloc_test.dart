import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/location/presentation/bloc/location_bloc.dart';
import 'package:quickqueue/features/location/presentation/bloc/location_event.dart';
import 'package:quickqueue/features/location/presentation/bloc/location_state.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  LocationBloc buildBloc() => LocationBloc(firestore: firestore);

  group('LoadLocationsEvent', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationsLoaded] with only open locations',
      build: () {
        firestore.collection('locations').doc('loc1').set({
          'name': 'Central Clinic',
          'isOpen': true,
        });
        firestore.collection('locations').doc('loc2').set({
          'name': 'Closed Clinic',
          'isOpen': false,
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadLocationsEvent()),
      expect: () => [
        const LocationLoading(),
        isA<LocationsLoaded>().having(
          (s) => s.locations.map((l) => l['name']).toList(),
          'location names',
          ['Central Clinic'],
        ),
      ],
    );
  });

  group('SearchLocationsEvent', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationsLoaded] filtered by query, case-insensitive',
      build: () {
        firestore.collection('locations').doc('loc1').set({
          'name': 'Central Clinic',
          'isOpen': true,
        });
        firestore.collection('locations').doc('loc2').set({
          'name': 'Northside Pharmacy',
          'isOpen': true,
        });
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const SearchLocationsEvent(query: 'central')),
      expect: () => [
        const LocationLoading(),
        isA<LocationsLoaded>().having(
          (s) => s.locations.map((l) => l['name']).toList(),
          'location names',
          ['Central Clinic'],
        ),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationsLoaded] with an empty list when nothing matches',
      build: () {
        firestore.collection('locations').doc('loc1').set({
          'name': 'Central Clinic',
          'isOpen': true,
        });
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const SearchLocationsEvent(query: 'nonexistent')),
      expect: () => [
        const LocationLoading(),
        const LocationsLoaded(locations: []),
      ],
    );
  });

  group('SelectLocationEvent', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationSelected] when the location exists',
      build: () {
        firestore.collection('locations').doc('loc1').set({
          'name': 'Central Clinic',
          'isOpen': true,
        });
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const SelectLocationEvent(locationId: 'loc1')),
      expect: () => [
        const LocationLoading(),
        isA<LocationSelected>()
            .having((s) => s.location['name'], 'name', 'Central Clinic'),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationError] when the location does not exist',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const SelectLocationEvent(locationId: 'missing')),
      expect: () => [
        const LocationLoading(),
        const LocationError(message: 'Location not found'),
      ],
    );
  });

  group('LoadServicesEvent', () {
    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, ServicesLoaded] with only active services for the location',
      build: () {
        firestore
            .collection('locations')
            .doc('loc1')
            .set({'name': 'Central Clinic'});
        firestore.collection('services').doc('svc1').set({
          'locationId': 'loc1',
          'isActive': true,
          'name': 'General Checkup',
        });
        firestore.collection('services').doc('svc2').set({
          'locationId': 'loc1',
          'isActive': false,
          'name': 'Inactive Service',
        });
        firestore.collection('services').doc('svc3').set({
          'locationId': 'loc2',
          'isActive': true,
          'name': 'Other Location Service',
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadServicesEvent(locationId: 'loc1')),
      expect: () => [
        const LocationLoading(),
        isA<ServicesLoaded>()
            .having((s) => s.locationName, 'locationName', 'Central Clinic')
            .having(
              (s) => s.services.map((svc) => svc['name']).toList(),
              'service names',
              ['General Checkup'],
            ),
      ],
    );
  });
}
