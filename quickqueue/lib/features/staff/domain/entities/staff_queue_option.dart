import 'package:equatable/equatable.dart';

/// A queue a staff member can pick during sign-up. Deliberately separate
/// from the customer-facing `QueueEntity` — that one doesn't carry
/// `counterLabel`, which sign-up needs to derive the staff member's counter.
class StaffQueueOption extends Equatable {
  const StaffQueueOption({
    required this.id,
    required this.name,
    required this.counterLabel,
  });

  final String id;
  final String name;
  final String counterLabel;

  @override
  List<Object?> get props => [id, name, counterLabel];
}
