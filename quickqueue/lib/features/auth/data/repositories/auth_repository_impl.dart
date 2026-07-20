import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> signInWithEmail({required String email, required String password}) {
    return _remoteDataSource.signInWithEmail(email: email, password: password);
  }

  @override
  Future<UserEntity> signInWithGoogle() => _remoteDataSource.signInWithGoogle();

  @override
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signUpWithEmail(name: name, email: email, password: password);
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
