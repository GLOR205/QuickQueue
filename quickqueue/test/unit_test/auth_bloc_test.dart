import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quickqueue/features/auth/presentaton/bloc/auth_bloc.dart';
import 'package:quickqueue/features/auth/presentaton/bloc/auth_event.dart';
import 'package:quickqueue/features/auth/presentaton/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockGoogleSignIn googleSignIn;
  late MockUser user;
  late MockUserCredential userCredential;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    googleSignIn = MockGoogleSignIn();
    user = MockUser();
    userCredential = MockUserCredential();
  });

  AuthBloc buildBloc() =>
      AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn);

  group('CheckAuthStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when a user is already signed in',
      build: () {
        when(firebaseAuth.currentUser).thenReturn(user);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
      expect: () => [AuthAuthenticated(user: user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when no user is signed in',
      build: () {
        when(firebaseAuth.currentUser).thenReturn(null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('SignInWithEmailEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(userCredential.user).thenReturn(user);
        when(firebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => userCredential);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithEmailEvent(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when FirebaseAuthException is thrown',
      build: () {
        when(firebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithEmailEvent(
        email: 'test@example.com',
        password: 'wrong',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Wrong password'),
      ],
    );
  });

  group('RegisterWithEmailEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthRegistrationSuccess] on success',
      build: () {
        when(userCredential.user).thenReturn(user);
        when(user.updateDisplayName(any)).thenAnswer((_) async {});
        when(firebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => userCredential);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RegisterWithEmailEvent(
        email: 'new@example.com',
        password: 'password123',
        fullName: 'New User',
      )),
      expect: () => [
        const AuthLoading(),
        AuthRegistrationSuccess(user: user),
      ],
      verify: (_) {
        verify(user.updateDisplayName('New User')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when registration fails',
      build: () {
        when(firebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use',
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RegisterWithEmailEvent(
        email: 'dup@example.com',
        password: 'password123',
        fullName: 'Dup User',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Email already in use'),
      ],
    );
  });

  group('SignInWithGoogleEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when the user cancels the picker',
      build: () {
        when(googleSignIn.signIn()).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful Google sign in',
      build: () {
        final googleAccount = MockGoogleSignInAccount();
        final googleAuth = MockGoogleSignInAuthentication();
        when(googleAuth.accessToken).thenReturn('access-token');
        when(googleAuth.idToken).thenReturn('id-token');
        when(googleAccount.authentication)
            .thenAnswer((_) async => googleAuth);
        when(googleSignIn.signIn()).thenAnswer((_) async => googleAccount);
        when(userCredential.user).thenReturn(user);
        when(firebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => userCredential);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: user),
      ],
    );
  });

  group('SignOutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on sign out',
      build: () {
        when(firebaseAuth.signOut()).thenAnswer((_) async {});
        when(googleSignIn.signOut()).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
