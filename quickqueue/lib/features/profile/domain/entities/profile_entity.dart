import 'package:equatable/equatable.dart';

class ProfileHistoryEntry extends Equatable {
  const ProfileHistoryEntry({
    required this.locationName,
    required this.serviceName,
    required this.dateLabel,
    required this.colorValue,
    required this.avatarLetter,
  });

  final String locationName;
  final String serviceName;
  final String dateLabel;

  /// ARGB color value used to tint the history entry's avatar chip.
  final int colorValue;
  final String avatarLetter;

  @override
  List<Object?> get props => [locationName, serviceName, dateLabel, colorValue, avatarLetter];
}

class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.name,
    required this.queuesJoined,
    required this.avgWaitMinutes,
    required this.timeSavedHours,
    required this.history,
  });

  final String name;
  final int queuesJoined;
  final int avgWaitMinutes;
  final double timeSavedHours;
  final List<ProfileHistoryEntry> history;

  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  @override
  List<Object?> get props => [name, queuesJoined, avgWaitMinutes, timeSavedHours, history];
}
