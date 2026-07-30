import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickqueue/features/queue/presentation/bloc/queue_bloc.dart';
import 'package:quickqueue/features/queue/presentation/bloc/queue_event.dart';
import 'package:quickqueue/features/queue/presentation/bloc/queue_state.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  QueueBloc buildBloc() => QueueBloc(firestore: firestore);

  group('JoinQueueEvent', () {
    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueJoined] when the queue exists',
      build: () {
        firestore.collection('queues').doc('queue1').set({
          'serviceId': 'service1',
          'locationId': 'location1',
          'totalWaiting': 2,
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const JoinQueueEvent(
        serviceId: 'service1',
        locationId: 'location1',
        userId: 'user1',
      )),
      expect: () => [
        const QueueLoading(),
        isA<QueueJoined>()
            .having((s) => s.ticketNumber, 'ticketNumber', 'A03')
            .having((s) => s.position, 'position', 3)
            .having((s) => s.estimatedWait, 'estimatedWait', 15)
            .having((s) => s.queueId, 'queueId', 'queue1')
            .having((s) => s.ticketId, 'ticketId', isNotEmpty),
      ],
      verify: (_) async {
        final queueDoc =
            await firestore.collection('queues').doc('queue1').get();
        expect(queueDoc.data()!['totalWaiting'], 3);

        final tickets = await firestore.collection('tickets').get();
        expect(tickets.docs.length, 1);
        expect(tickets.docs.first.data()['userId'], 'user1');
        expect(tickets.docs.first.data()['status'], 'waiting');
      },
    );

    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueError] when no matching queue is found',
      build: buildBloc,
      act: (bloc) => bloc.add(const JoinQueueEvent(
        serviceId: 'missing-service',
        locationId: 'missing-location',
        userId: 'user1',
      )),
      expect: () => [
        const QueueLoading(),
        const QueueError(message: 'Queue not found'),
      ],
    );
  });

  group('LeaveQueueEvent', () {
    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueLeft] and updates ticket/queue documents',
      build: () {
        firestore
            .collection('tickets')
            .doc('ticket1')
            .set({'status': 'waiting'});
        firestore
            .collection('queues')
            .doc('queue1')
            .set({'totalWaiting': 3});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LeaveQueueEvent(
        ticketId: 'ticket1',
        queueId: 'queue1',
      )),
      expect: () => [
        const QueueLoading(),
        const QueueLeft(),
      ],
      verify: (_) async {
        final ticketDoc =
            await firestore.collection('tickets').doc('ticket1').get();
        expect(ticketDoc.data()!['status'], 'left');

        final queueDoc =
            await firestore.collection('queues').doc('queue1').get();
        expect(queueDoc.data()!['totalWaiting'], 2);
      },
    );
  });

  group('GetQueuePositionEvent', () {
    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueUpdated] when the ticket exists',
      build: () {
        firestore.collection('tickets').doc('ticket1').set({
          'ticketNumber': 'A05',
          'position': 5,
          'estimatedWait': 25,
          'currentNumber': 'A02',
          'counter': 'C2',
        });
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const GetQueuePositionEvent(ticketId: 'ticket1')),
      expect: () => [
        const QueueLoading(),
        const QueueUpdated(
          ticketNumber: 'A05',
          position: 5,
          estimatedWait: 25,
          currentNumber: 'A02',
          counter: 'C2',
        ),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueError] when the ticket does not exist',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const GetQueuePositionEvent(ticketId: 'missing-ticket')),
      expect: () => [
        const QueueLoading(),
        const QueueError(message: 'Ticket not found'),
      ],
    );
  });

  group('LoadQueueEvent', () {
    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueUpdated] when the queue exists',
      build: () {
        firestore.collection('queues').doc('queue1').set({
          'totalWaiting': 4,
          'currentNumber': 'A01',
          'counterNumber': 'C1',
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadQueueEvent(queueId: 'queue1')),
      expect: () => [
        const QueueLoading(),
        const QueueUpdated(
          ticketNumber: '',
          position: 4,
          estimatedWait: 20,
          currentNumber: 'A01',
          counter: 'C1',
        ),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'emits [QueueLoading, QueueError] when the queue does not exist',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadQueueEvent(queueId: 'missing-queue')),
      expect: () => [
        const QueueLoading(),
        const QueueError(message: 'Queue not found'),
      ],
    );
  });

  group('QueueUpdatedEvent', () {
    blocTest<QueueBloc, QueueState>(
      'emits [QueueUpdated] built directly from the event payload',
      build: buildBloc,
      act: (bloc) => bloc.add(const QueueUpdatedEvent(queueData: {
        'ticketNumber': 'A07',
        'position': 7,
        'estimatedWait': 35,
        'currentNumber': 'A03',
        'counter': 'C3',
      })),
      expect: () => [
        const QueueUpdated(
          ticketNumber: 'A07',
          position: 7,
          estimatedWait: 35,
          currentNumber: 'A03',
          counter: 'C3',
        ),
      ],
    );

    blocTest<QueueBloc, QueueState>(
      'falls back to defaults for missing fields in the event payload',
      build: buildBloc,
      act: (bloc) => bloc.add(const QueueUpdatedEvent(queueData: {})),
      expect: () => [
        const QueueUpdated(
          ticketNumber: '',
          position: 0,
          estimatedWait: 0,
          currentNumber: 'A01',
          counter: 'C1',
        ),
      ],
    );
  });
}
