import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';

class CallNotificationManager {
  CallNotificationManager._internal();
  factory CallNotificationManager() => _instance;
  static final CallNotificationManager _instance =
      CallNotificationManager._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Stream to handle notification actions (Accept/Decline)
  final _actionController = StreamController<String>.broadcast();
  Stream<String> get onAction => _actionController.stream;

  static const String channelId = 'call_channel_high_importance';
  static const String channelName = 'Incoming Calls';
  static const String channelDesc =
      'Notifications for incoming video and audio calls';

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final iosSettings = DarwinInitializationSettings(
      // Configure actions for iOS 10+
      notificationCategories: [
        DarwinNotificationCategory(
          'call_category',
          actions: [
            DarwinNotificationAction.plain(
              'accept_call',
              'Accept',
              options: {DarwinNotificationActionOption.foreground},
            ),
            DarwinNotificationAction.plain(
              'decline_call',
              'Decline',
              options: {DarwinNotificationActionOption.destructive},
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          // Handle tap on notification body
          _actionController.add('tap');
        }
        if (response.actionId != null) {
          _actionController.add(response.actionId!);
        }
      },
      // Handle background actions
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> showIncomingNotification(CallSession session) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'accept_call',
          'Accept',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction('decline_call', 'Decline'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'call_category',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      session.id.hashCode, // Unique Int ID
      'SehatApp',
      'Incoming ${session.type == CallType.video ? "Video" : "Audio"} Call from ${session.callerName}',
      details,
      payload: session.id,
    );
  }

  Future<void> cancel(String sessionId) async {
    await _notifications.cancel(sessionId.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

// Top-level function for background handling
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  // Can specific background logic if needed, but for now we just let the app open
  // or handle via Stream if app is in background but running.
  // Note: Isolate limitations apply here.
}
