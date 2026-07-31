import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../../queue/domain/entities/ticket_entity.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/staff_queue_option.dart';
import '../../domain/entities/staff_ticket_record.dart';

abstract class StaffRemoteDataSource {
  Future<StaffEntity> signIn({required String email, required String password});

  Future<StaffEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String locationId,
    required String locationName,
    required String queueId,
    required String counterLabel,
  });

  Future<void> signOut();

  Future<List<StaffQueueOption>> getQueueOptions(String locationId);

  Future<List<TicketEntity>> getQueueTickets(String queueId);

  Future<List<StaffTicketRecord>> getQueueTicketHistory(String queueId);

  Future<void> markServed(String ticketId);

  Future<void> skipTicket(String ticketId);
}

/// Signs staff in against Firebase Auth, then confirms the account is
/// actually registered as staff via a `staff/{uid}` Firestore doc (created
/// by an admin — the security rules don't allow the app to write it).
/// Queue tickets are read from the same `tickets` collection the customer
/// side writes to, filtered to the staff member's assigned queue.
class FirebaseStaffRemoteDataSource implements StaffRemoteDataSource {
  FirebaseStaffRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<StaffEntity> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;
      final staffDoc = await _firestore.collection('staff').doc(uid).get();
      final data = staffDoc.data();
      if (!staffDoc.exists || data == null) {
        await _auth.signOut();
        throw const ValidationException('This account is not registered as staff.');
      }
      return StaffEntity(
        id: uid,
        name: (data['name'] as String?) ?? '',
        email: (data['email'] as String?) ?? email,
        locationId: (data['locationId'] as String?) ?? '',
        locationName: (data['locationName'] as String?) ?? '',
        queueId: (data['queueId'] as String?) ?? '',
        counterLabel: (data['counterLabel'] as String?) ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapAuthError(e.code));
    }
  }

  @override
  Future<StaffEntity> signUp({
    required String name,
    required String email,
    required String password,
    required String locationId,
    required String locationName,
    required String queueId,
    required String counterLabel,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(name);
      await _firestore.collection('staff').doc(uid).set({
        'name': name,
        'email': email,
        'locationId': locationId,
        'locationName': locationName,
        'queueId': queueId,
        'counterLabel': counterLabel,
      });
      return StaffEntity(
        id: uid,
        name: name,
        email: email,
        locationId: locationId,
        locationName: locationName,
        queueId: queueId,
        counterLabel: counterLabel,
      );
    } on FirebaseAuthException catch (e) {
      throw ValidationException(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<List<StaffQueueOption>> getQueueOptions(String locationId) async {
    final snapshot = await _firestore
        .collection('queues')
        .where('locationId', isEqualTo: locationId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return StaffQueueOption(
        id: (data['id'] as String?) ?? doc.id,
        name: (data['name'] as String?) ?? '',
        counterLabel: (data['counterLabel'] as String?) ?? '',
      );
    }).toList();
  }

  @override
  Future<List<TicketEntity>> getQueueTickets(String queueId) async {
    final snapshot = await _firestore.collection('tickets').where('queueId', isEqualTo: queueId).get();
    final activeDocs = snapshot.docs.where((doc) {
      final status = doc.data()['status'] as String?;
      return status == 'waiting' || status == 'almostReady';
    }).toList()
      ..sort((a, b) {
        final aPos = (a.data()['positionInQueue'] as num?)?.toInt() ?? 0;
        final bPos = (b.data()['positionInQueue'] as num?)?.toInt() ?? 0;
        return aPos.compareTo(bPos);
      });
    return activeDocs.map((doc) => _ticketFromData(doc.id, doc.data())).toList();
  }

  @override
  Future<List<StaffTicketRecord>> getQueueTicketHistory(String queueId) async {
    final snapshot = await _firestore.collection('tickets').where('queueId', isEqualTo: queueId).get();
    final records = snapshot.docs.map((doc) {
      final data = doc.data();
      return StaffTicketRecord(
        ticketNumber: (data['ticketNumber'] as String?) ?? doc.id,
        status: (data['status'] as String?) ?? 'waiting',
        estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num?)?.toInt() ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList()
      ..sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    return records;
  }

  @override
  Future<void> markServed(String ticketId) {
    return _firestore.collection('tickets').doc(ticketId).update({'status': 'served'});
  }

  @override
  Future<void> skipTicket(String ticketId) {
    return _firestore.collection('tickets').doc(ticketId).update({'status': 'skipped'});
  }

  TicketEntity _ticketFromData(String id, Map<String, dynamic> data) {
    return TicketEntity(
      ticketNumber: (data['ticketNumber'] as String?) ?? id,
      queueName: (data['queueName'] as String?) ?? '',
      locationName: (data['locationName'] as String?) ?? '',
      positionInQueue: (data['positionInQueue'] as num?)?.toInt() ?? 0,
      totalInQueue: (data['totalInQueue'] as num?)?.toInt() ?? 0,
      nowServingNumber: (data['nowServingNumber'] as String?) ?? '',
      estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num?)?.toInt() ?? 0,
      counterLabel: (data['counterLabel'] as String?) ?? '',
      status: (data['status'] as String?) == 'almostReady' ? TicketStatus.almostReady : TicketStatus.waiting,
    );
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No staff account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
