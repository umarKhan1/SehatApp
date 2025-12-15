import 'package:sehatapp/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Stream<List<NotificationEntity>> getNotificationsStream();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
