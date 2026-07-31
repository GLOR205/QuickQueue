import 'package:equatable/equatable.dart';

class StaffEntity extends Equatable {
  const StaffEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.locationId,
    required this.locationName,
    required this.queueId,
    required this.counterLabel,
  });

  final String id;
  final String name;
  final String email;
  final String locationId;
  final String locationName;
  final String queueId;
  final String counterLabel;

  @override
  List<Object?> get props =>
      [id, name, email, locationId, locationName, queueId, counterLabel];
}
