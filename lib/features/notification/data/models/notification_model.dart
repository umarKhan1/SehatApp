import 'package:sehatapp/features/notification/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.timestamp,
    super.isRead,
    super.unreadCount,
    super.iconUrl,
    super.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      iconUrl: json['iconUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
    );
  }
}
