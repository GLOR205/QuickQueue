import '../entities/coordinates.dart';
import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<List<LocationEntity>> getLocations();

  Future<Coordinates> getCurrentPosition();
}
