import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickqueue/features/auth/presentaton/bloc/auth_bloc.dart';
import 'package:quickqueue/features/staff/presentation/screens/staff_login_screen.dart';
import 'package:quickqueue/features/staff/widgets/custom_text_field.dart';

import '../unit_test/auth_bloc_test.mocks.dart';

void main() {
  Finder fieldWithLabel(String label) => find.descendant(
        of: find.byWidgetPredicate(
            (w) => w is CustomTextField && w.label == label),
        matching: find.byType(TextFormField),
      );

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

  testWidgets('submits the entered credentials and shows a loading state',
      (tester) async {
    when(userCredential.user).thenReturn(user);
    // Never resolved, so the test can observe the loading state without
    // letting the bloc reach AuthAuthenticated, which would navigate to
    // QueueDashboardScreen and hit real Firebase in this test environment.
    final pendingSignIn = Completer<UserCredential>();
    when(firebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) => pendingSignIn.future);

    await tester.pumpWidget(MaterialApp(
      home: StaffLoginScreen(
        authBloc: AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      ),
    ));

    await tester.enterText(
        fieldWithLabel('Staff ID or email'),
        'staff@hospital.rw');
    await tester.enterText(
        fieldWithLabel('Password'), 'password123');

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Signing in...'), findsOneWidget);
    verify(firebaseAuth.signInWithEmailAndPassword(
      email: 'staff@hospital.rw',
      password: 'password123',
    )).called(1);
  });

  testWidgets('shows an error message when sign-in fails', (tester) async {
    when(firebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: 'Wrong password'));

    await tester.pumpWidget(MaterialApp(
      home: StaffLoginScreen(
        authBloc: AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      ),
    ));

    await tester.enterText(
        fieldWithLabel('Staff ID or email'),
        'staff@hospital.rw');
    await tester.enterText(
        fieldWithLabel('Password'), 'wrong');

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Wrong password'), findsOneWidget);
  });

  testWidgets('validates required fields before submitting', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: StaffLoginScreen(
        authBloc: AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      ),
    ));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your staff ID or email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(firebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    ));
  });
}
