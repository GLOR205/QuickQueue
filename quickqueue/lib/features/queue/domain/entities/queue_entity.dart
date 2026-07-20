import 'package:equatable/equatable.dart';

/// Represents a single service queue at a location (e.g. "General
/// Consultation" at a hospital), as listed on the Services screen.
class QueueEntity extends Equatable {
  const QueueEntity({
    required this.id,
    required this.name,
    required this.waitingCount,
    required this.estimatedWaitMinutes,
    this.isPriority = false,
    this.etaLabel,
  });

  final String id;
  final String name;
  final int waitingCount;
  final int estimatedWaitMinutes;
  final bool isPriority;

  /// Overrides the generated "~N min" label, e.g. "Immediate" for emergency queues.
  final String? etaLabel;

  String get waitLabel => etaLabel ?? '~$estimatedWaitMinutes min';

  @override
  List<Object?> get props => [id, name, waitingCount, estimatedWaitMinutes, isPriority, etaLabel];
}
