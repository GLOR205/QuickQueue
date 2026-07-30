import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:quickqueue/features/staff/presentation/screens/skip_screen.dart';

void main() {
  testWidgets('selecting a reason and confirming skips the patient',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('tickets').doc('ticket1').set({
      'status': 'waiting',
    });
    await firestore.collection('queues').doc('queue1').set({
      'totalWaiting': 1,
    });

    // Push on top of a base route so the in-screen Navigator.pop() has
    // somewhere to land, matching how the real app always reaches this
    // screen from another one.
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: SizedBox.shrink()),
    ));
    navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (_) => SkipScreen(
        ticketId: 'ticket1',
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patient not present'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm skip'));
    await tester.pumpAndSettle();

    expect(find.text('Patient skipped: Patient not present'), findsOneWidget);
    final ticket = await firestore.collection('tickets').doc('ticket1').get();
    expect(ticket.data()!['status'], 'skipped');
    final skipReasons = await firestore.collection('skipReasons').get();
    expect(skipReasons.docs.single.data()['reason'], 'Patient not present');
  });

  testWidgets('Confirm skip does nothing until a reason is picked',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('tickets').doc('ticket1').set({
      'status': 'waiting',
    });

    await tester.pumpWidget(MaterialApp(
      home: SkipScreen(
        ticketId: 'ticket1',
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm skip'));
    await tester.pumpAndSettle();

    final ticket = await firestore.collection('tickets').doc('ticket1').get();
    expect(ticket.data()!['status'], 'waiting');
  });
}
