feature/user-screens
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_queue_position.dart';
import '../../domain/usecases/get_queues.dart';
import '../../domain/usecases/join_queue.dart';
import '../../domain/usecases/leave_queue.dart';
import 'queue_event.dart';
import 'queue_state.dart';

/// Session-scoped: one instance lives for the whole authenticated session
/// (provided at the app root) so an active ticket and its live position
/// updates survive navigating between the Locations/Services flow and the
/// Ticket/Alerts/Profile shell tabs.
class QueueBloc extends Bloc<QueueEvent, QueueState> {
  QueueBloc({
    required GetQueues getQueues,
    required JoinQueue joinQueue,
    required GetQueuePosition getQueuePosition,
    required LeaveQueue leaveQueue,
    required GetNotifications getNotifications,
  })  : _getQueues = getQueues,
        _joinQueue = joinQueue,
        _getQueuePosition = getQueuePosition,
        _leaveQueue = leaveQueue,
        _getNotifications = getNotifications,
        super(const QueueState()) {
    on<QueuesRequested>(_onQueuesRequested);
    on<QueueSelected>(_onQueueSelected);
    on<QueueJoinRequested>(_onQueueJoinRequested);
    on<TicketWatchStarted>(_onTicketWatchStarted);
    on<TicketUpdated>(_onTicketUpdated);
    on<QueueLeaveRequested>(_onQueueLeaveRequested);
    on<NotificationsRequested>(_onNotificationsRequested);
  }

  final GetQueues _getQueues;
  final JoinQueue _joinQueue;
  final GetQueuePosition _getQueuePosition;
  final LeaveQueue _leaveQueue;
  final GetNotifications _getNotifications;
  StreamSubscription<dynamic>? _ticketSubscription;

  Future<void> _onQueuesRequested(QueuesRequested event, Emitter<QueueState> emit) async {
    emit(state.copyWith(status: QueueStatus.loading));
    try {
      final queues = await _getQueues(event.locationId);
      emit(state.copyWith(
        status: QueueStatus.loaded,
        queues: queues,
        selectedQueue: queues.isNotEmpty ? queues.first : null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: QueueStatus.error, errorMessage: e.message));
    }
  }

  void _onQueueSelected(QueueSelected event, Emitter<QueueState> emit) {
    emit(state.copyWith(selectedQueue: event.queue));
  }

  Future<void> _onQueueJoinRequested(QueueJoinRequested event, Emitter<QueueState> emit) async {
    final queue = state.selectedQueue;
    if (queue == null) return;
    emit(state.copyWith(status: QueueStatus.joining));
    try {
      final ticket = await _joinQueue(
        locationId: event.locationId,
        locationName: event.locationName,
        queue: queue,
      );
      emit(state.copyWith(status: QueueStatus.joined, ticket: ticket));
      _watchTicket(ticket.ticketNumber);
      try {
        final notifications = await _getNotifications();
        emit(state.copyWith(notifications: notifications));
      } catch (_) {
        // Non-fatal: the join itself already succeeded above.
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: QueueStatus.error, errorMessage: e.message));
    }
  }

  Future<void> _onTicketWatchStarted(TicketWatchStarted event, Emitter<QueueState> emit) async {
    emit(state.copyWith(status: QueueStatus.loaded, ticket: event.ticket));
    _watchTicket(event.ticket.ticketNumber);
  }

  void _watchTicket(String ticketNumber) {
    _ticketSubscription?.cancel();
    _ticketSubscription = _getQueuePosition(ticketNumber).listen((ticket) {
      add(TicketUpdated(ticket));
    });
  }

  void _onTicketUpdated(TicketUpdated event, Emitter<QueueState> emit) {
    // Guard against a stray update landing after the ticket's already been
    // left (or superseded) — on<TicketUpdated> and on<QueueLeaveRequested>
    // run concurrently, so a position update queued right as the user taps
    // "Leave queue" could otherwise resurrect the ticket after it's cleared.
    if (state.ticket == null || state.ticket!.ticketNumber != event.ticket.ticketNumber) return;
    emit(state.copyWith(ticket: event.ticket));
  }

  Future<void> _onQueueLeaveRequested(QueueLeaveRequested event, Emitter<QueueState> emit) async {
    final ticket = state.ticket;
    if (ticket == null) return;
    emit(state.clearTicket());
    await _ticketSubscription?.cancel();
    await _leaveQueue(ticket.ticketNumber);
  }

  Future<void> _onNotificationsRequested(NotificationsRequested event, Emitter<QueueState> emit) async {
    emit(state.copyWith(status: QueueStatus.loading));
    try {
      final notifications = await _getNotifications();
      emit(state.copyWith(status: QueueStatus.loaded, notifications: notifications));
    } on AppException catch (e) {
      emit(state.copyWith(status: QueueStatus.error, errorMessage: e.message));
    }
  }

  @override
  Future<void> close() {
    _ticketSubscription?.cancel();
    return super.close();
  }
}

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
main
