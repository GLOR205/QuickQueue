import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final FirebaseFirestore firestore;

  StaffBloc({required this.firestore}) : super(const StaffInitial()) {
    on<LoadQueueDashboardEvent>(_onLoadQueueDashboard);
    on<MarkServedEvent>(_onMarkServed);
    on<SkipPatientEvent>(_onSkipPatient);
    on<PauseQueueEvent>(_onPauseQueue);
    on<ResumeQueueEvent>(_onResumeQueue);
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
  }

  Future<void> _onLoadQueueDashboard(
    LoadQueueDashboardEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      final queueDoc = await firestore
          .collection('queues')
          .doc(event.queueId)
          .get();

      if (!queueDoc.exists) {
        emit(const StaffError(message: 'Queue not found'));
        return;
      }

      final queueData = queueDoc.data()!;

      final ticketsSnapshot = await firestore
          .collection('tickets')
          .where('queueId', isEqualTo: event.queueId)
          .where('status', isEqualTo: 'waiting')
          .orderBy('position')
          .get();

      final queueList = ticketsSnapshot.docs
          .map((doc) => doc.data())
          .toList();

      emit(QueueDashboardLoaded(
        currentTicket: queueData['currentNumber'] as String? ?? 'A01',
        totalWaiting: queueData['totalWaiting'] as int? ?? 0,
        totalServed: queueData['totalServed'] as int? ?? 0,
        isPaused: queueData['isPaused'] as bool? ?? false,
        queueList: queueList,
      ));
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> _onMarkServed(
    MarkServedEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      await firestore
          .collection('tickets')
          .doc(event.ticketId)
          .update({
        'status': 'served',
        'servedAt': FieldValue.serverTimestamp(),
      });

      await firestore
          .collection('queues')
          .doc(event.queueId)
          .update({
        'totalWaiting': FieldValue.increment(-1),
        'totalServed': FieldValue.increment(1),
      });

      emit(const PatientServedSuccess());
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> _onSkipPatient(
    SkipPatientEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      await firestore
          .collection('tickets')
          .doc(event.ticketId)
          .update({'status': 'skipped'});

      await firestore.collection('skipReasons').add({
        'ticketId': event.ticketId,
        'queueId': event.queueId,
        'reason': event.reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await firestore
          .collection('queues')
          .doc(event.queueId)
          .update({'totalWaiting': FieldValue.increment(-1)});

      emit(const PatientSkippedSuccess());
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> _onPauseQueue(
    PauseQueueEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      await firestore
          .collection('queues')
          .doc(event.queueId)
          .update({
        'isPaused': true,
        'pauseReason': event.reason,
      });

      emit(const QueuePausedSuccess());
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> _onResumeQueue(
    ResumeQueueEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      await firestore
          .collection('queues')
          .doc(event.queueId)
          .update({
        'isPaused': false,
        'pauseReason': '',
      });

      emit(const QueueResumedSuccess());
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    try {
      final analyticsSnapshot = await firestore
          .collection('analytics')
          .where('locationId', isEqualTo: event.locationId)
          .where('serviceId', isEqualTo: event.serviceId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (analyticsSnapshot.docs.isEmpty) {
        emit(const AnalyticsLoaded(
          totalServed: 0,
          totalSkipped: 0,
          avgWaitTime: 0,
          peakHour: 'N/A',
          hourlyData: {},
        ));
        return;
      }

      final data = analyticsSnapshot.docs.first.data();
      emit(AnalyticsLoaded(
        totalServed: data['totalServed'] as int? ?? 0,
        totalSkipped: data['totalSkipped'] as int? ?? 0,
        avgWaitTime: (data['avgWaitTime'] as num?)?.toDouble() ?? 0,
        peakHour: data['peakHour'] as String? ?? 'N/A',
        hourlyData: data['hourlyData'] as Map<String, dynamic>? ?? {},
      ));
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }
}