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
