import 'package:sehatapp/features/notification/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  MarkAllNotificationsReadUseCase(this.repository);
  final NotificationRepository repository;

  Future<void> call() async {
    await repository.markAllAsRead();
  }
}
