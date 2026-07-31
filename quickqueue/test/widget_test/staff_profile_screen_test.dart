import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quickqueue/features/auth/presentaton/bloc/auth_bloc.dart';
import 'package:quickqueue/features/staff/presentation/screens/staff_profile_screen.dart';

import '../unit_test/auth_bloc_test.mocks.dart';

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockGoogleSignIn googleSignIn;

  setUp(() async {
    firebaseAuth = MockFirebaseAuth();
    googleSignIn = MockGoogleSignIn();
  });

  Future<void> useTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('shows Queue Control only when a queueId is known',
      (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(MaterialApp(
      home: StaffProfileScreen(
        queueId: 'queue1',
        authBloc: AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Queue Control'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: StaffProfileScreen(
        authBloc: AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Queue Control'), findsNothing);
  });

  testWidgets('tapping Sign out dispatches SignOutEvent and shows a loading state',
      (tester) async {
    await useTallSurface(tester);
    // Never resolved, so the test can observe the loading state without
    // letting the bloc reach AuthUnauthenticated, which would navigate to
    // StaffLoginScreen and hit real Firebase in this test environment.
    final pendingSignOut = Completer<void>();
    when(firebaseAuth.signOut()).thenAnswer((_) => pendingSignOut.future);
    when(googleSignIn.signOut()).thenAnswer((_) async => null);

    await tester.pumpWidget(MaterialApp(
      home: StaffProfileScreen(
        queueId: 'queue1',
        authBloc: AuthBloc(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pump();

    expect(find.text('Signing out...'), findsOneWidget);
    verify(firebaseAuth.signOut()).called(1);
  });
}
