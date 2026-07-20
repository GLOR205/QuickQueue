import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileEntity> getProfile() => _remoteDataSource.getProfile();

  @override
  Future<void> submitRating({
    required int stars,
    required String comment,
    required String serviceName,
  }) {
    return _remoteDataSource.submitRating(stars: stars, comment: comment, serviceName: serviceName);
  }
}
