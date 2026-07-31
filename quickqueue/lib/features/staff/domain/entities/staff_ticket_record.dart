import 'package:equatable/equatable.dart';

/// A ticket record as staff need it for analytics/alerts — carries the raw
/// Firestore status string and creation time, neither of which the
/// customer-facing `TicketEntity` exposes (its `TicketStatus` enum has no
/// "skipped" state, and it has no timestamp at all).
class StaffTicketRecord extends Equatable {
  const StaffTicketRecord({
    required this.ticketNumber,
    required this.status,
    required this.estimatedWaitMinutes,
    required this.createdAt,
  });

  final String ticketNumber;

  /// 'waiting' | 'almostReady' | 'served' | 'skipped'
  final String status;
  final int estimatedWaitMinutes;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [ticketNumber, status, estimatedWaitMinutes, createdAt];
}
