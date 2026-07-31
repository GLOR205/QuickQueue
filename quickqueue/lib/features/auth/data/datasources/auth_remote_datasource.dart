import 'dart:math';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toEntity(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapAuthError(e.code));
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const ValidationException('Google sign-in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      await _saveUserToFirestore(user);
      return _toEntity(user);
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapAuthError(e.code));
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name);
      await user.reload();
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': name,
        'email': email,
        'photoUrl': null,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserEntity(
        id: user.uid,
        name: name,
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> _saveUserToFirestore(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'id': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  UserEntity _toEntity(User user) {
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? user.email!.split('@').first,
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
