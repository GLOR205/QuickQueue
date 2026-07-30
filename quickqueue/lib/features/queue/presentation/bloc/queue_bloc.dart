import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'queue_event.dart';
import 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final FirebaseFirestore firestore;
  final Uuid _uuid = const Uuid();

  QueueBloc({required this.firestore}) : super(const QueueInitial()) {
    on<JoinQueueEvent>(_onJoinQueue);
    on<LeaveQueueEvent>(_onLeaveQueue);
    on<GetQueuePositionEvent>(_onGetQueuePosition);
    on<LoadQueueEvent>(_onLoadQueue);
    on<QueueUpdatedEvent>(_onQueueUpdated);
  }

  Future<void> _onJoinQueue(
    JoinQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    try {
      final queueSnapshot = await firestore
          .collection('queues')
          .where('serviceId', isEqualTo: event.serviceId)
          .where('locationId', isEqualTo: event.locationId)
          .limit(1)
          .get();

      if (queueSnapshot.docs.isEmpty) {
        emit(const QueueError(message: 'Queue not found'));
        return;
      }

      final queueDoc = queueSnapshot.docs.first;
      final queueData = queueDoc.data();
      final totalWaiting = queueData['totalWaiting'] as int? ?? 0;
      final position = totalWaiting + 1;
      final ticketNumber =
          'A${position.toString().padLeft(2, '0')}';
      final ticketId = _uuid.v4();

      await firestore.collection('tickets').doc(ticketId).set({
        'ticketId': ticketId,
        'userId': event.userId,
        'queueId': queueDoc.id,
        'serviceId': event.serviceId,
        'locationId': event.locationId,
        'ticketNumber': ticketNumber,
        'position': position,
        'status': 'waiting',
        'estimatedWait': position * 5,
        'joinedAt': FieldValue.serverTimestamp(),
        'servedAt': null,
        'timeSaved': 0,
      });

      await firestore
          .collection('queues')
          .doc(queueDoc.id)
          .update({'totalWaiting': FieldValue.increment(1)});

      emit(QueueJoined(
        ticketId: ticketId,
        ticketNumber: ticketNumber,
        position: position,
        estimatedWait: position * 5,
        queueId: queueDoc.id,
      ));
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  Future<void> _onLeaveQueue(
    LeaveQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    try {
      await firestore
          .collection('tickets')
          .doc(event.ticketId)
          .update({'status': 'left'});

      await firestore
          .collection('queues')
          .doc(event.queueId)
          .update({'totalWaiting': FieldValue.increment(-1)});

      emit(const QueueLeft());
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  Future<void> _onGetQueuePosition(
    GetQueuePositionEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    try {
      final ticketDoc = await firestore
          .collection('tickets')
          .doc(event.ticketId)
          .get();

      if (!ticketDoc.exists) {
        emit(const QueueError(message: 'Ticket not found'));
        return;
      }

      final data = ticketDoc.data()!;
      emit(QueueUpdated(
        ticketNumber: data['ticketNumber'] as String,
        position: data['position'] as int,
        estimatedWait: data['estimatedWait'] as int,
        currentNumber: data['currentNumber'] as String? ?? 'A01',
        counter: data['counter'] as String? ?? 'C1',
      ));
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  Future<void> _onLoadQueue(
    LoadQueueEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(const QueueLoading());
    try {
      final queueDoc = await firestore
          .collection('queues')
          .doc(event.queueId)
          .get();

      if (!queueDoc.exists) {
        emit(const QueueError(message: 'Queue not found'));
        return;
      }

      final data = queueDoc.data()!;
      emit(QueueUpdated(
        ticketNumber: '',
        position: data['totalWaiting'] as int? ?? 0,
        estimatedWait: (data['totalWaiting'] as int? ?? 0) * 5,
        currentNumber: data['currentNumber'] as String? ?? 'A01',
        counter: data['counterNumber'] as String? ?? 'C1',
      ));
    } catch (e) {
      emit(QueueError(message: e.toString()));
    }
  }

  void _onQueueUpdated(
    QueueUpdatedEvent event,
    Emitter<QueueState> emit,
  ) {
    final data = event.queueData;
    emit(QueueUpdated(
      ticketNumber: data['ticketNumber'] as String? ?? '',
      position: data['position'] as int? ?? 0,
      estimatedWait: data['estimatedWait'] as int? ?? 0,
      currentNumber: data['currentNumber'] as String? ?? 'A01',
      counter: data['counter'] as String? ?? 'C1',
    ));
  }
}