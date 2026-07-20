import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUpWithEmail(name: name, email: email, password: password);
  }
}
