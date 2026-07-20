import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quickqueue/features/auth/presentaton/screens/index_screen.dart';
import 'package:quickqueue/features/auth/presentaton/screens/register_screen.dart';
import 'package:quickqueue/features/location/domain/entities/location_entity.dart';
import 'package:quickqueue/features/location/presentation/screens/locations_screen.dart';
import 'package:quickqueue/features/profile/presentation/screens/rating_screen.dart';
import 'package:quickqueue/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:quickqueue/features/queue/domain/entities/ticket_entity.dart';
import 'package:quickqueue/features/queue/presentation/screens/my_ticket_screen.dart';
import 'package:quickqueue/features/queue/presentation/screens/notifications_screen.dart';
import 'package:quickqueue/features/queue/presentation/screens/services_screens.dart';

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

  testWidgets('LocationsScreen loads locations', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocationsScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('King Faisal Hospital'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('ServicesScreen loads queues', (tester) async {
    const location = LocationEntity(
      id: 'loc-1',
      name: 'King Faisal Hospital',
      area: 'Kigali',
      district: 'Kacyiru',
      category: LocationCategory.hospital,
      colorValue: 0xFF2B7A78,
    );
    await tester.pumpWidget(const MaterialApp(home: ServicesScreen(location: location)));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('General Consultation'), findsOneWidget);
    expect(find.text('Join selected queue'), findsOneWidget);
  });

  testWidgets('MyTicketScreen renders ticket', (tester) async {
    const ticket = TicketEntity(
      ticketNumber: 'A46',
      queueName: 'General Consultation',
      locationName: 'King Faisal',
      positionInQueue: 6,
      totalInQueue: 7,
      nowServingNumber: 'A43',
      estimatedWaitMinutes: 18,
      counterLabel: 'C2',
    );
    await tester.pumpWidget(const MaterialApp(home: MyTicketScreen(ticket: ticket)));
    await tester.pump();
    expect(find.text('A46'), findsOneWidget);
    expect(find.text('Leave queue'), findsOneWidget);
  });

  testWidgets('NotificationsScreen loads notifications', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationsScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Queue joined successfully'), findsOneWidget);
  });

  testWidgets('UserProfileScreen loads profile', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserProfileScreen()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Recent queue history'), findsOneWidget);
  });

  testWidgets('RatingScreen requires a star before submit is enabled', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RatingScreen(serviceName: 'General Consultation', roomLabel: 'Room - C2'),
    ));
    await tester.pump();
    expect(find.text('Service completed'), findsOneWidget);
    final submitButton =
        tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit feedback'));
    expect(submitButton.onPressed, isNull);
  });
}
