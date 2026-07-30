import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:quickqueue/features/staff/presentation/screens/analytics_screen.dart';

void main() {
  testWidgets('loads analytics for the queue\'s location/service and renders them',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'locationId': 'loc1',
      'serviceId': 'svc1',
    });
    await firestore.collection('analytics').doc('a1').set({
      'locationId': 'loc1',
      'serviceId': 'svc1',
      'date': DateTime(2026, 1, 1),
      'totalServed': 47,
      'totalSkipped': 1,
      'avgWaitTime': 13.0,
      'peakHour': '9 AM',
      'hourlyData': {'8': 6, '9': 12},
    });

    await tester.pumpWidget(MaterialApp(
      home: AnalyticsScreen(
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
        firestore: firestore,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('47'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(find.text('9 AM'), findsOneWidget);
    expect(find.text('8:00'), findsOneWidget);
    expect(find.text('9:00'), findsOneWidget);
  });

  testWidgets('shows zeroed defaults when no analytics document exists',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('queues').doc('queue1').set({
      'locationId': 'loc1',
      'serviceId': 'svc1',
    });

    await tester.pumpWidget(MaterialApp(
      home: AnalyticsScreen(
        queueId: 'queue1',
        staffBloc: StaffBloc(firestore: firestore),
        firestore: firestore,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('N/A'), findsOneWidget);
    expect(find.text('No hourly data yet'), findsOneWidget);
  });
}
