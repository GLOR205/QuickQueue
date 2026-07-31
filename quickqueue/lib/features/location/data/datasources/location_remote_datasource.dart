import '../../domain/entities/location_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // KG 544 St, Kacyiru — https://en.wikipedia.org/wiki/King_Faisal_Hospital_(Kigali)
        latitude: -1.94361,
        longitude: 30.09500,
      ),
      LocationEntity(
        id: 'loc-bank-of-kigali',
        name: 'Bank of Kigali',
        area: 'Kigali',
        district: 'Nyarugenge',
        category: LocationCategory.bank,
        colorValue: 0xFF6C63B5,
        // HQ, 6112 KN 4 Ave — https://en.wikipedia.org/wiki/Bank_of_Kigali
        latitude: -1.948333,
        longitude: 30.059722,
      ),
      LocationEntity(
        id: 'loc-chuk',
        name: 'CHUK Hospital',
        area: 'Kigali',
        district: 'Nyarugenge',
        category: LocationCategory.hospital,
        colorValue: 0xFF3E8E5A,
        // KN 4 Ave — https://en.wikipedia.org/wiki/University_Teaching_Hospital_of_Kigali
        latitude: -1.9505113,
        longitude: 30.0601826,
      ),
      LocationEntity(
        id: 'loc-bpr',
        name: 'BPR Bank',
        area: 'Kigali',
        district: 'Nyarugenge',
        category: LocationCategory.bank,
        colorValue: 0xFF6C63B5,
        // Head office, KN 30 St, Kiyovu — https://mapcarta.com/N9984147058
        latitude: -1.9472,
        longitude: 30.0600,
      ),
    ];
  }
}
class FirebaseLocationRemoteDataSource implements LocationRemoteDataSource {
  FirebaseLocationRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<LocationEntity>> getLocations() async {
    final snapshot = await _firestore.collection('location').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final categoryValue = (data['category'] ?? data['Category'] ?? '') as String;
      return LocationEntity(
        id: (data['id'] as String?) ?? doc.id,
        name: ((data['name'] as String?) ?? '').trim(),
        area: (data['area'] as String?) ?? '',
        district: (data['district'] as String?) ?? '',
        category: categoryValue.toLowerCase() == 'hospital'
            ? LocationCategory.hospital
            : LocationCategory.bank,
        colorValue: (data['colorValue'] as num?)?.toInt() ?? 0xFF2B7A78,
        latitude: (data['latitude'] as num?)?.toDouble() ?? -1.9441,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 30.0619,
      );
    }).toList();
  }
}
