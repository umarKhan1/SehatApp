class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.unreadCount = 0,
    this.iconUrl,
    this.type = NotificationType.general,
  });
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isRead;
  final int
  unreadCount; // For the badge inside the notification item (e.g. grouped events)
  final String? iconUrl; // URL or asset path. If null, use default app icon.
  final NotificationType type;
}

enum NotificationType { reminder, mention, general, message, post }
