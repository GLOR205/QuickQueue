import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:quickqueue/features/staff/presentation/screens/queue_dashboard_screen.dart';

void main() {
  Future<void> pumpDashboard(
    WidgetTester tester, {
    required FakeFirebaseFirestore firestore,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: QueueDashboardScreen(
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the waiting queue loaded from Firestore', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'currentNumber': 'A43',
      'totalWaiting': 2,
      'totalServed': 28,
      'isPaused': false,
    });
    await firestore.collection('tickets').doc('t1').set({
      'ticketId': 't1',
      'queueId': 'queue1',
      'status': 'waiting',
      'position': 1,
      'ticketNumber': 'A43',
    });
    await firestore.collection('tickets').doc('t2').set({
      'ticketId': 't2',
      'queueId': 'queue1',
      'status': 'waiting',
      'position': 2,
      'ticketNumber': 'A44',
    });

    await pumpDashboard(tester, firestore: firestore);

    expect(find.text('A43'), findsOneWidget);
    expect(find.text('A44'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // "Waiting now" stat tile
    expect(find.text('28'), findsOneWidget); // "Served today" stat tile
  });

  testWidgets('shows an empty state when there is nothing waiting',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'currentNumber': 'A01',
      'totalWaiting': 0,
      'totalServed': 0,
      'isPaused': false,
    });

    await pumpDashboard(tester, firestore: firestore);

    expect(find.text('Queue is empty'), findsOneWidget);
  });

  testWidgets('marking the first patient as served updates Firestore',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'currentNumber': 'A43',
      'totalWaiting': 1,
      'totalServed': 0,
      'isPaused': false,
    });
    await firestore.collection('tickets').doc('t1').set({
      'ticketId': 't1',
      'queueId': 'queue1',
      'status': 'waiting',
      'position': 1,
      'ticketNumber': 'A43',
    });

    await pumpDashboard(tester, firestore: firestore);

    await tester.tap(find.text('Mark Served'));
    await tester.pumpAndSettle();

    expect(find.text('Patient marked as served'), findsOneWidget);
    final ticket = await firestore.collection('tickets').doc('t1').get();
    expect(ticket.data()!['status'], 'served');
  });
}
