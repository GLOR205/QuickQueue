import 'package:equatable/equatable.dart';

enum NotificationType { positionUpdate, joined, waitTimeChanged }

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeLabel,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeLabel;

  @override
  List<Object?> get props => [id, type, title, message, timeLabel];
}
