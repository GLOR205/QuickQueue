import 'dart:math';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signInWithEmail({required String email, required String password});

  Future<UserEntity> signInWithGoogle();

  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

/// In-memory stand-in for the Firebase Auth integration. Implements the same
/// [AuthRemoteDataSource] contract so it can be swapped for a Firestore/
/// firebase_auth backed implementation without touching the repository,
/// use cases, bloc, or screens above it.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<UserEntity> signInWithEmail({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (password.length < 6) {
      throw const ValidationException('Incorrect email or password.');
    }
    return UserEntity(
      id: 'user-${email.hashCode}',
      name: email.split('@').first,
      email: email,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const UserEntity(
      id: 'user-google',
      name: 'Google User',
      email: 'user@gmail.com',
    );
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return UserEntity(
      id: 'user-${Random().nextInt(1 << 31)}',
      name: name,
      email: email,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
