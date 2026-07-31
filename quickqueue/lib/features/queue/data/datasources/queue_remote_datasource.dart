import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/entities/ticket_entity.dart';

abstract class QueueRemoteDataSource {
  Future<List<QueueEntity>> getQueues(String locationId);

  Future<TicketEntity> joinQueue({
    required String locationId,
    required String locationName,
    required QueueEntity queue,
  });

  Stream<TicketEntity> watchTicket(String ticketNumber);

  Future<void> leaveQueue(String ticketNumber);

  Future<List<NotificationEntity>> getNotifications();
}

/// In-memory stand-in for the Firestore-backed queue/ticket collections.
/// Simulates a ticket's position ticking down over time so the presentation
/// layer can demonstrate live BLoC state updates before the real Firestore
/// listeners are wired in. Implements the same [QueueRemoteDataSource]
/// contract so it can be swapped out without touching the layers above it.
class MockQueueRemoteDataSource implements QueueRemoteDataSource {
  static const _bankLocationIds = {'loc-bank-of-kigali', 'loc-bpr'};

  static const _hospitalQueues = [
    QueueEntity(
      id: 'q-general',
      name: 'General Consultation',
      waitingCount: 5,
      estimatedWaitMinutes: 32,
    ),
    QueueEntity(
      id: 'q-lab',
      name: 'Laboratory / Tests',
      waitingCount: 5,
      estimatedWaitMinutes: 14,
    ),
    QueueEntity(
      id: 'q-pharmacy',
      name: 'Pharmacy',
      waitingCount: 3,
      estimatedWaitMinutes: 8,
    ),
    QueueEntity(
      id: 'q-emergency',
      name: 'Emergency',
      waitingCount: 0,
      estimatedWaitMinutes: 0,
      isPriority: true,
      etaLabel: 'Immediate',
    ),
    QueueEntity(
      id: 'q-radiology',
      name: 'Radiology',
      waitingCount: 7,
      estimatedWaitMinutes: 20,
    ),
  ];

  static const _bankQueues = [
    QueueEntity(
      id: 'q-teller',
      name: 'Teller / Cash Services',
      waitingCount: 6,
      estimatedWaitMinutes: 12,
    ),
    QueueEntity(
      id: 'q-account-opening',
      name: 'Account Opening',
      waitingCount: 3,
      estimatedWaitMinutes: 18,
    ),
    QueueEntity(
      id: 'q-loans',
      name: 'Loans & Credit',
      waitingCount: 2,
      estimatedWaitMinutes: 25,
    ),
    QueueEntity(
      id: 'q-customer-care',
      name: 'Customer Care',
      waitingCount: 4,
      estimatedWaitMinutes: 10,
    ),
    QueueEntity(
      id: 'q-forex',
      name: 'Forex Exchange',
      waitingCount: 1,
      estimatedWaitMinutes: 6,
    ),
  ];

  final Map<String, TicketEntity> _tickets = {};
  final Map<String, StreamController<TicketEntity>> _controllers = {};
  final Map<String, Timer> _timers = {};
  int _ticketSeed = 46;

  @override
  Future<List<QueueEntity>> getQueues(String locationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bankLocationIds.contains(locationId) ? _bankQueues : _hospitalQueues;
  }

  @override
  Future<TicketEntity> joinQueue({
    required String locationId,
    required String locationName,
    required QueueEntity queue,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final numberSeed = _ticketSeed;
    _ticketSeed++;
    final ticket = TicketEntity(
      ticketNumber: 'A$numberSeed',
      queueName: queue.name,
      locationName: locationName,
      positionInQueue: queue.waitingCount + 1,
      totalInQueue: queue.waitingCount + 2,
      nowServingNumber: 'A${numberSeed - 3}',
      estimatedWaitMinutes: (queue.estimatedWaitMinutes * 0.55).round(),
      counterLabel: 'C2',
    );
    _tickets[ticket.ticketNumber] = ticket;
    _startSimulation(ticket.ticketNumber);
    return ticket;
  }

  void _startSimulation(String ticketNumber) {
    _timers[ticketNumber]?.cancel();
    _timers[ticketNumber] = Timer.periodic(const Duration(seconds: 5), (timer) {
      final current = _tickets[ticketNumber];
      if (current == null || current.status == TicketStatus.served) {
        timer.cancel();
        return;
      }
      final nextPosition = current.positionInQueue - 1;
      final updated = nextPosition <= 0
          ? current.copyWith(positionInQueue: 0, estimatedWaitMinutes: 0, status: TicketStatus.served)
          : current.copyWith(
              positionInQueue: nextPosition,
              estimatedWaitMinutes: (current.estimatedWaitMinutes - 4) < 0 ? 0 : current.estimatedWaitMinutes - 4,
              status: nextPosition <= 2 ? TicketStatus.almostReady : TicketStatus.waiting,
            );
      _tickets[ticketNumber] = updated;
      _controllers[ticketNumber]?.add(updated);
      if (updated.status == TicketStatus.served) timer.cancel();
    });
  }

  @override
  Stream<TicketEntity> watchTicket(String ticketNumber) {
    final controller =
        _controllers.putIfAbsent(ticketNumber, () => StreamController<TicketEntity>.broadcast());
    return controller.stream;
  }

  @override
  Future<void> leaveQueue(String ticketNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _timers.remove(ticketNumber)?.cancel();
    _tickets.remove(ticketNumber);
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      NotificationEntity(
        id: 'n-1',
        type: NotificationType.positionUpdate,
        title: '2 people ahead of you!',
        message: 'You are A46. Room - R2.',
        timeLabel: 'Just now',
      ),
      NotificationEntity(
        id: 'n-2',
        type: NotificationType.joined,
        title: 'Queue joined successfully',
        message: 'You joined General Consultation. Your number is A47.',
        timeLabel: 'Earlier today',
      ),
      NotificationEntity(
        id: 'n-3',
        type: NotificationType.waitTimeChanged,
        title: 'Wait time updated',
        message: 'Estimate changed from 32 min to 18 min.',
        timeLabel: 'Earlier today',
      ),
    ];
  }
}

/// Reads queues from Firestore and persists tickets/notifications there too.
/// The actual position-ticking-down behavior is still driven by the in-memory
/// [MockQueueRemoteDataSource] simulator (no staff-side app exists yet to
/// drive real position updates) — but every tick is mirrored into the
/// ticket's Firestore doc, and a notification doc is written on join, so
/// both show up as real, persisted records (profile history, alerts) rather
/// than disappearing when the session ends.
class FirebaseQueueRemoteDataSource implements QueueRemoteDataSource {
  FirebaseQueueRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final MockQueueRemoteDataSource _ticketSimulator = MockQueueRemoteDataSource();
  final Map<String, StreamSubscription<TicketEntity>> _mirrorSubscriptions = {};

  @override
  Future<List<QueueEntity>> getQueues(String locationId) async {
    final snapshot = await _firestore
        .collection('queues')
        .where('locationId', isEqualTo: locationId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return QueueEntity(
        id: data['id'] as String,
        name: data['name'] as String,
        waitingCount: (data['waitingCount'] as num).toInt(),
        estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num).toInt(),
        isPriority: data['isPriority'] as bool? ?? false,
        etaLabel: data['etaLabel'] as String?,
      );
    }).toList();
  }

  @override
  Future<TicketEntity> joinQueue({
    required String locationId,
    required String locationName,
    required QueueEntity queue,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const ValidationException('You must be signed in to join a queue.');
    }

    final ticket = await _ticketSimulator.joinQueue(
      locationId: locationId,
      locationName: locationName,
      queue: queue,
    );

    var locationColorValue = 0xFF2B7A78;
    var avatarLetter = 'H';
    try {
      final locationData = (await _firestore.collection('location').doc(locationId).get()).data();
      if (locationData != null) {
        locationColorValue = (locationData['colorValue'] as num?)?.toInt() ?? locationColorValue;
        final category = (locationData['category'] ?? locationData['Category'] ?? '') as String;
        avatarLetter = category.toLowerCase() == 'hospital' ? 'H' : 'B';
      }
    } catch (_) {
      // Best-effort styling only — history still works without exact colors.
    }

    final ticketDoc = _firestore.collection('tickets').doc(ticket.ticketNumber);
    await ticketDoc.set({
      'userId': uid,
      'ticketNumber': ticket.ticketNumber,
      'locationId': locationId,
      'locationName': locationName,
      'queueId': queue.id,
      'queueName': ticket.queueName,
      'positionInQueue': ticket.positionInQueue,
      'totalInQueue': ticket.totalInQueue,
      'nowServingNumber': ticket.nowServingNumber,
      'estimatedWaitMinutes': ticket.estimatedWaitMinutes,
      'counterLabel': ticket.counterLabel,
      'status': _statusName(ticket.status),
      'colorValue': locationColorValue,
      'avatarLetter': avatarLetter,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('notifications').add({
      'userId': uid,
      'type': 'joined',
      'title': 'Queue joined successfully',
      'message': 'You joined ${ticket.queueName}. Your number is ${ticket.ticketNumber}.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _mirrorSubscriptions.remove(ticket.ticketNumber)?.cancel();
    _mirrorSubscriptions[ticket.ticketNumber] =
        _ticketSimulator.watchTicket(ticket.ticketNumber).listen((updated) {
      ticketDoc.update({
        'positionInQueue': updated.positionInQueue,
        'estimatedWaitMinutes': updated.estimatedWaitMinutes,
        'status': _statusName(updated.status),
      });
    });

    return ticket;
  }

  @override
  Stream<TicketEntity> watchTicket(String ticketNumber) => _ticketSimulator.watchTicket(ticketNumber);

  @override
  Future<void> leaveQueue(String ticketNumber) async {
    await _mirrorSubscriptions.remove(ticketNumber)?.cancel();
    await _ticketSimulator.leaveQueue(ticketNumber);
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const [];
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .get();
    final docs = snapshot.docs.toList()
      ..sort((a, b) {
        final aTime = a.data()['createdAt'] as Timestamp?;
        final bTime = b.data()['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
    return docs.map((doc) {
      final data = doc.data();
      return NotificationEntity(
        id: (data['id'] as String?) ?? doc.id,
        type: _parseNotificationType(data['type'] as String?),
        title: (data['title'] as String?) ?? '',
        message: (data['message'] as String?) ?? '',
        timeLabel: (data['timeLabel'] as String?) ?? _relativeTimeLabel(data['createdAt'] as Timestamp?),
      );
    }).toList();
  }

  NotificationType _parseNotificationType(String? value) {
    switch (value) {
      case 'joined':
        return NotificationType.joined;
      case 'waitTimeChanged':
        return NotificationType.waitTimeChanged;
      default:
        return NotificationType.positionUpdate;
    }
  }

  String _statusName(TicketStatus status) {
    switch (status) {
      case TicketStatus.served:
        return 'served';
      case TicketStatus.almostReady:
        return 'almostReady';
      case TicketStatus.waiting:
        return 'waiting';
    }
  }

  String _relativeTimeLabel(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 2) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
