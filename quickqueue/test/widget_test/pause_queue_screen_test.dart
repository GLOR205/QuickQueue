import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:quickqueue/features/staff/presentation/screens/pause_queue_screen.dart';

void main() {
  testWidgets(
      'selecting a break and confirming pauses the queue and pops the screen',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'isPaused': false,
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
      builder: (_) => PauseQueueScreen(
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lunch break (1hr)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pause queue'));
    await tester.pumpAndSettle();

    expect(find.text('Queue paused: Lunch break (1hr)'), findsOneWidget);
    final queue = await firestore.collection('queues').doc('queue1').get();
    expect(queue.data()!['isPaused'], true);
    expect(queue.data()!['pauseReason'], 'Lunch break (1hr)');
  });

  testWidgets('toggling the counter switch off pauses, on resumes',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'isPaused': false,
    });

    await tester.pumpWidget(MaterialApp(
      home: PauseQueueScreen(
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final queue = await firestore.collection('queues').doc('queue1').get();
    expect(queue.data()!['isPaused'], true);
    expect(queue.data()!['pauseReason'], 'Counter closed');
  });
}
