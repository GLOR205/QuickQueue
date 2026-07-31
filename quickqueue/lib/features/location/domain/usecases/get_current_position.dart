import '../entities/coordinates.dart';
import '../repositories/location_repository.dart';

class GetCurrentPosition {
  const GetCurrentPosition(this._repository);

  final LocationRepository _repository;

  Future<Coordinates> call() => _repository.getCurrentPosition();
}
