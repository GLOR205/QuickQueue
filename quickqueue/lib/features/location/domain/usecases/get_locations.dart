import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetLocations {
  const GetLocations(this._repository);

  final LocationRepository _repository;

  Future<List<LocationEntity>> call() => _repository.getLocations();
}
