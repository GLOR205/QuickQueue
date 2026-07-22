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
    required this.email,
    required this.phone,
    required this.queuesJoined,
    required this.avgWaitMinutes,
    required this.timeSavedHours,
    required this.history,
    this.notificationsEnabled = true,
    this.languageCode = 'en',
  });

  final String name;
  final String email;
  final String phone;
  final int queuesJoined;
  final int avgWaitMinutes;
  final double timeSavedHours;
  final List<ProfileHistoryEntry> history;
  final bool notificationsEnabled;

  /// 'en', 'rw' (Kinyarwanda), or 'fr'. UI-only preference for now — no
  /// translated strings are wired up yet, this just persists the choice.
  final String languageCode;

  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  ProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    bool? notificationsEnabled,
    String? languageCode,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      queuesJoined: queuesJoined,
      avgWaitMinutes: avgWaitMinutes,
      timeSavedHours: timeSavedHours,
      history: history,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        queuesJoined,
        avgWaitMinutes,
        timeSavedHours,
        history,
        notificationsEnabled,
        languageCode,
      ];
}
