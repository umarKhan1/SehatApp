import 'package:sehatapp/features/notification/domain/entities/notification_entity.dart';
import 'package:sehatapp/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  GetNotificationsUseCase(this.repository);
  final NotificationRepository repository;

  Future<List<NotificationEntity>> call() async {
    return await repository.getNotifications();
  }

  Stream<List<NotificationEntity>> callStream() {
    return repository.getNotificationsStream();
  }
}
