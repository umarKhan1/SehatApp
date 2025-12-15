import 'package:sehatapp/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  MarkNotificationReadUseCase(this.repository);
  final NotificationRepository repository;

  Future<void> call(String id) async {
    await repository.markAsRead(id);
  }
}
