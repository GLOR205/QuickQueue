import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quickqueue/core/navigation/home_shell.dart';
import 'package:quickqueue/core/navigation/nav_tab_cubit.dart';
import 'package:quickqueue/core/theme/theme_cubit.dart';
import 'package:quickqueue/features/auth/presentaton/screens/index_screen.dart';
import 'package:quickqueue/features/auth/presentaton/screens/register_screen.dart';
import 'package:quickqueue/features/location/domain/entities/location_entity.dart';
import 'package:quickqueue/features/location/presentation/screens/locations_screen.dart';
import 'package:quickqueue/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:quickqueue/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:quickqueue/features/profile/domain/usecases/change_password.dart';
import 'package:quickqueue/features/profile/domain/usecases/get_user_profile.dart';
import 'package:quickqueue/features/profile/domain/usecases/submit_rating.dart';
import 'package:quickqueue/features/profile/domain/usecases/update_preferences.dart';
import 'package:quickqueue/features/profile/domain/usecases/update_profile.dart';
import 'package:quickqueue/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quickqueue/features/profile/presentation/screens/rating_screen.dart';
import 'package:quickqueue/features/queue/data/datasources/queue_remote_datasource.dart';
import 'package:quickqueue/features/queue/data/repositories/queue_repository_impl.dart';
import 'package:quickqueue/features/queue/domain/usecases/get_notifications.dart';
import 'package:quickqueue/features/queue/domain/usecases/get_queue_position.dart';
import 'package:quickqueue/features/queue/domain/usecases/get_queues.dart';
import 'package:quickqueue/features/queue/domain/usecases/join_queue.dart';
import 'package:quickqueue/features/queue/domain/usecases/leave_queue.dart';
import 'package:quickqueue/features/queue/presentation/bloc/queue_bloc.dart';

/// Mirrors the app-root providers wired in lib/main.dart, so tests exercise
/// the same session-scoped bloc composition as the real app.
Widget _appProviders({required Widget child}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ThemeCubit()),
      BlocProvider(create: (_) => NavTabCubit()),
      BlocProvider(create: (_) {
        final repository = QueueRepositoryImpl(MockQueueRemoteDataSource());
        return QueueBloc(
          getQueues: GetQueues(repository),
          joinQueue: JoinQueue(repository),
          getQueuePosition: GetQueuePosition(repository),
          leaveQueue: LeaveQueue(repository),
          getNotifications: GetNotifications(repository),
        );
      }),
      BlocProvider(create: (_) {
        final repository = ProfileRepositoryImpl(MockProfileRemoteDataSource());
        return ProfileBloc(
          getUserProfile: GetUserProfile(repository),
          submitRating: SubmitRating(repository),
          updateProfile: UpdateProfile(repository),
          changePassword: ChangePassword(repository),
          updatePreferences: UpdatePreferences(repository),
        );
      }),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('IndexScreen renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: IndexScreen()));
    await tester.pump();
    expect(find.text('Quick Queue'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders and validates', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    await tester.pump();
    expect(find.text('Create account'), findsWidgets);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pump();
    expect(find.text('Full name is required'), findsOneWidget);
  });

  testWidgets('LocationsScreen loads locations for its category', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LocationsScreen(category: LocationCategory.hospital)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('King Faisal Hospital'), findsOneWidget);
    expect(find.text('Bank of Kigali'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('HomeShell starts on an empty ticket state', (tester) async {
    await tester.pumpWidget(_appProviders(child: const HomeShell()));
    await tester.pumpAndSettle();
    expect(find.text('No active ticket'), findsOneWidget);
    expect(find.text('Find a queue'), findsOneWidget);
  });

  testWidgets(
    'joining a queue from the shell shows the ticket, and switching tabs no longer loses it',
    (tester) async {
      await tester.pumpWidget(_appProviders(child: const HomeShell()));
      await tester.pumpAndSettle();

      // Ticket tab -> find a queue -> categories -> Locations -> Services -> join.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Find a queue'));
      await tester.pumpAndSettle();
      expect(find.text('Hospital Services'), findsOneWidget);

      await tester.tap(find.text('Hospital Services'));
      await tester.pumpAndSettle();
      expect(find.text('King Faisal Hospital'), findsWidgets);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.text('General Consultation'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Join selected queue'));
      await tester.pumpAndSettle();

      // Joining pops back to the shell's Ticket tab with the new ticket.
      expect(find.text('Leave queue'), findsOneWidget);
      expect(find.text('No active ticket'), findsNothing);

      // Regression check: switching to Alerts then Profile then back to
      // Ticket must NOT strand the user or lose the active ticket — this is
      // the exact bug being fixed (pushReplacement/pop losing the route).
      await tester.tap(find.text('Alerts'));
      await tester.pumpAndSettle();
      expect(find.text('Leave queue'), findsNothing);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Recent queue history'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);

      await tester.tap(find.text('Ticket'));
      await tester.pumpAndSettle();
      expect(find.text('Leave queue'), findsOneWidget);

      // Run the mock's position simulation through to "served" (it ticks
      // down every 5 fake seconds) so its internal timer cancels itself,
      // rather than leaving a pending Timer for flutter_test's teardown
      // check to trip on.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(seconds: 5));
      }
    },
  );

  testWidgets('RatingScreen requires a star before submit is enabled', (tester) async {
    await tester.pumpWidget(_appProviders(
      child: const RatingScreen(serviceName: 'General Consultation', roomLabel: 'Room - C2'),
    ));
    await tester.pump();
    expect(find.text('Service completed'), findsOneWidget);
    final submitButton =
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit feedback'));
    expect(submitButton.onPressed, isNull);
  });
}
