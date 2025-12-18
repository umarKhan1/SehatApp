import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/notification/domain/entities/notification_entity.dart';
import 'package:sehatapp/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:sehatapp/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:sehatapp/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:sehatapp/features/notification/presentation/cubit/notification_cubit.dart';

class MockGetNotificationsUseCase extends Mock
    implements GetNotificationsUseCase {}

class MockMarkNotificationReadUseCase extends Mock
    implements MarkNotificationReadUseCase {}

class MockMarkAllNotificationsReadUseCase extends Mock
    implements MarkAllNotificationsReadUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationCubit cubit;
  late MockGetNotificationsUseCase mockGetNotifications;
  late MockMarkNotificationReadUseCase mockMarkAsRead;
  late MockMarkAllNotificationsReadUseCase mockMarkAllAsRead;

  setUp(() {
    mockGetNotifications = MockGetNotificationsUseCase();
    mockMarkAsRead = MockMarkNotificationReadUseCase();
    mockMarkAllAsRead = MockMarkAllNotificationsReadUseCase();

    // Setup default behavior
    when(
      () => mockGetNotifications.callStream(),
    ).thenAnswer((_) => Stream.value([]));

    cubit = NotificationCubit(
      getNotificationsUseCase: mockGetNotifications,
      markNotificationReadUseCase: mockMarkAsRead,
      markAllNotificationsReadUseCase: mockMarkAllAsRead,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('NotificationCubit', () {
    final mockNotifications = [
      NotificationEntity(
        id: 'notif1',
        title: 'New Message',
        subtitle: 'You have a new message',
        type: NotificationType.message,
        timestamp: DateTime.now(),
      ),
      NotificationEntity(
        id: 'notif2',
        title: 'New Post',
        subtitle: 'Someone posted a blood request',
        type: NotificationType.post,
        timestamp: DateTime.now(),
      ),
    ];

    test('initial state has empty notifications', () {
      expect(cubit.state.notifications, isEmpty);
    });

    test('load notifications fetches from use case', () async {
      // Setup
      when(
        () => mockGetNotifications.callStream(),
      ).thenAnswer((_) => Stream.value(mockNotifications));

      // Create cubit (constructor calls loadNotifications)
      final testCubit = NotificationCubit(
        getNotificationsUseCase: mockGetNotifications,
        markNotificationReadUseCase: mockMarkAsRead,
        markAllNotificationsReadUseCase: mockMarkAllAsRead,
      );

      // Wait for stream to emit
      await Future.delayed(Duration(milliseconds: 100));

      // Verify
      expect(testCubit.state.notifications, mockNotifications);
      expect(testCubit.state.loading, isFalse);

      testCubit.close();
    });

    blocTest<NotificationCubit, NotificationState>(
      'mark notification as read updates state',
      setUp: () {
        when(() => mockMarkAsRead.call(any())).thenAnswer((_) async => {});
      },
      build: () => cubit,
      seed: () => NotificationState(notifications: mockNotifications),
      act: (cubit) => cubit.markAsRead('notif1'),
      verify: (_) {
        verify(() => mockMarkAsRead.call('notif1')).called(1);
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'mark all as read updates all notifications',
      setUp: () {
        when(() => mockMarkAllAsRead.call()).thenAnswer((_) async => {});
      },
      build: () => cubit,
      seed: () => NotificationState(notifications: mockNotifications),
      act: (cubit) => cubit.markAllRead(),
      verify: (_) {
        verify(() => mockMarkAllAsRead.call()).called(1);
      },
    );
  });
}
