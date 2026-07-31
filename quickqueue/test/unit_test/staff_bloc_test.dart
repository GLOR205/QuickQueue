import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_event.dart';
import 'package:quickqueue/features/staff/presentation/bloc/staff_state.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  StaffBloc buildBloc() => StaffBloc(firestore: firestore);

  group('LoadQueueDashboardEvent', () {
    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, QueueDashboardLoaded] with waiting tickets ordered by position',
      build: () {
        firestore.collection('queues').doc('queue1').set({
          'currentNumber': 'A01',
          'totalWaiting': 2,
          'totalServed': 5,
          'isPaused': false,
        });
        firestore.collection('tickets').doc('t1').set({
          'queueId': 'queue1',
          'status': 'waiting',
          'position': 2,
        });
        firestore.collection('tickets').doc('t2').set({
          'queueId': 'queue1',
          'status': 'waiting',
          'position': 1,
        });
        firestore.collection('tickets').doc('t3').set({
          'queueId': 'queue1',
          'status': 'served',
          'position': 0,
        });
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadQueueDashboardEvent(queueId: 'queue1')),
      expect: () => [
        const StaffLoading(),
        isA<QueueDashboardLoaded>()
            .having((s) => s.currentTicket, 'currentTicket', 'A01')
            .having((s) => s.totalWaiting, 'totalWaiting', 2)
            .having((s) => s.totalServed, 'totalServed', 5)
            .having((s) => s.isPaused, 'isPaused', false)
            .having(
              (s) => s.queueList.map((t) => t['position']).toList(),
              'queueList order',
              [1, 2],
            ),
      ],
    );

    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, StaffError] when the queue does not exist',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const LoadQueueDashboardEvent(queueId: 'missing-queue')),
      expect: () => [
        const StaffLoading(),
        const StaffError(message: 'Queue not found'),
      ],
    );
  });

  group('MarkServedEvent', () {
    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, PatientServedSuccess] and updates ticket/queue counters',
      build: () {
        firestore
            .collection('tickets')
            .doc('ticket1')
            .set({'status': 'waiting'});
        firestore.collection('queues').doc('queue1').set({
          'totalWaiting': 3,
          'totalServed': 5,
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MarkServedEvent(
        ticketId: 'ticket1',
        queueId: 'queue1',
      )),
      expect: () => [
        const StaffLoading(),
        const PatientServedSuccess(),
      ],
      verify: (_) async {
        final ticket =
            await firestore.collection('tickets').doc('ticket1').get();
        expect(ticket.data()!['status'], 'served');

        final queue =
            await firestore.collection('queues').doc('queue1').get();
        expect(queue.data()!['totalWaiting'], 2);
        expect(queue.data()!['totalServed'], 6);
      },
    );
  });

  group('SkipPatientEvent', () {
    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, PatientSkippedSuccess], records the reason, and decrements totalWaiting',
      build: () {
        firestore
            .collection('tickets')
            .doc('ticket1')
            .set({'status': 'waiting'});
        firestore.collection('queues').doc('queue1').set({
          'totalWaiting': 3,
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SkipPatientEvent(
        ticketId: 'ticket1',
        queueId: 'queue1',
        reason: 'No show',
      )),
      expect: () => [
        const StaffLoading(),
        const PatientSkippedSuccess(),
      ],
      verify: (_) async {
        final ticket =
            await firestore.collection('tickets').doc('ticket1').get();
        expect(ticket.data()!['status'], 'skipped');

        final queue =
            await firestore.collection('queues').doc('queue1').get();
        expect(queue.data()!['totalWaiting'], 2);

        final skipReasons = await firestore.collection('skipReasons').get();
        expect(skipReasons.docs.length, 1);
        expect(skipReasons.docs.first.data()['reason'], 'No show');
      },
    );
  });

  group('PauseQueueEvent', () {
    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, QueuePausedSuccess] and marks the queue paused',
      build: () {
        firestore.collection('queues').doc('queue1').set({
          'isPaused': false,
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PauseQueueEvent(
        queueId: 'queue1',
        reason: 'Staff break',
      )),
      expect: () => [
        const StaffLoading(),
        const QueuePausedSuccess(),
      ],
      verify: (_) async {
        final queue =
            await firestore.collection('queues').doc('queue1').get();
        expect(queue.data()!['isPaused'], true);
        expect(queue.data()!['pauseReason'], 'Staff break');
      },
    );
  });

  group('ResumeQueueEvent', () {
    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, QueueResumedSuccess] and clears the pause reason',
      build: () {
        firestore.collection('queues').doc('queue1').set({
          'isPaused': true,
          'pauseReason': 'Staff break',
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ResumeQueueEvent(queueId: 'queue1')),
      expect: () => [
        const StaffLoading(),
        const QueueResumedSuccess(),
      ],
      verify: (_) async {
        final queue =
            await firestore.collection('queues').doc('queue1').get();
        expect(queue.data()!['isPaused'], false);
        expect(queue.data()!['pauseReason'], '');
      },
    );
  });

  group('LoadAnalyticsEvent', () {
    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, AnalyticsLoaded] from the most recent analytics document',
      build: () {
        firestore.collection('analytics').doc('a1').set({
          'locationId': 'loc1',
          'serviceId': 'svc1',
          'date': DateTime(2026, 1, 1),
          'totalServed': 10,
          'totalSkipped': 2,
          'avgWaitTime': 8.5,
          'peakHour': '10:00',
          'hourlyData': {'10': 5},
        });
        firestore.collection('analytics').doc('a2').set({
          'locationId': 'loc1',
          'serviceId': 'svc1',
          'date': DateTime(2026, 1, 2),
          'totalServed': 20,
          'totalSkipped': 1,
          'avgWaitTime': 6.0,
          'peakHour': '11:00',
          'hourlyData': {'11': 8},
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadAnalyticsEvent(
        locationId: 'loc1',
        serviceId: 'svc1',
      )),
      expect: () => [
        const StaffLoading(),
        isA<AnalyticsLoaded>()
            .having((s) => s.totalServed, 'totalServed', 20)
            .having((s) => s.totalSkipped, 'totalSkipped', 1)
            .having((s) => s.avgWaitTime, 'avgWaitTime', 6.0)
            .having((s) => s.peakHour, 'peakHour', '11:00'),
      ],
    );

    blocTest<StaffBloc, StaffState>(
      'emits [StaffLoading, AnalyticsLoaded] with zeroed defaults when no analytics exist',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadAnalyticsEvent(
        locationId: 'missing-loc',
        serviceId: 'missing-svc',
      )),
      expect: () => [
        const StaffLoading(),
        const AnalyticsLoaded(
          totalServed: 0,
          totalSkipped: 0,
          avgWaitTime: 0,
          peakHour: 'N/A',
          hourlyData: {},
        ),
      ],
    );
  });
}
