import '../../domain/entities/coordinates.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/device_location_datasource.dart';
import '../datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._remoteDataSource, this._deviceLocationDataSource);

  final LocationRemoteDataSource _remoteDataSource;
  final DeviceLocationDataSource _deviceLocationDataSource;

  @override
  Future<List<LocationEntity>> getLocations() => _remoteDataSource.getLocations();

  @override
  Future<Coordinates> getCurrentPosition() => _deviceLocationDataSource.getCurrentPosition();
}
