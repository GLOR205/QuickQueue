import '../../domain/entities/location_entity.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationEntity>> getLocations();
}

/// In-memory stand-in for the Firestore-backed locations collection.
/// Implements the same [LocationRemoteDataSource] contract so it can be
/// swapped for a real implementation without touching the layers above it.
class MockLocationRemoteDataSource implements LocationRemoteDataSource {
  @override
  Future<List<LocationEntity>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      LocationEntity(
        id: 'loc-king-faisal',
        name: 'King Faisal Hospital',
        area: 'Kigali',
        district: 'Kacyiru',
        category: LocationCategory.hospital,
        colorValue: 0xFF2B7A78,
        latitude: -1.9436,
        longitude: 30.0906,
      ),
      LocationEntity(
        id: 'loc-bank-of-kigali',
        name: 'Bank of Kigali',
        area: 'Kigali',
        district: 'Nyarugenge',
        category: LocationCategory.bank,
        colorValue: 0xFF6C63B5,
        latitude: -1.9500,
        longitude: 30.0588,
      ),
      LocationEntity(
        id: 'loc-chuk',
        name: 'CHUK Hospital',
        area: 'Kigali',
        district: 'Nyarugenge',
        category: LocationCategory.hospital,
        colorValue: 0xFF3E8E5A,
        latitude: -1.9548,
        longitude: 30.0505,
      ),
      LocationEntity(
        id: 'loc-bpr',
        name: 'BPR Bank',
        area: 'Kigali',
        district: 'Nyarugenge',
        category: LocationCategory.bank,
        colorValue: 0xFF6C63B5,
        latitude: -1.9482,
        longitude: 30.0605,
      ),
    ];
  }
}
