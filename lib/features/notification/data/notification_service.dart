import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehatapp/core/router/app_router.dart';
import 'package:sehatapp/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  NotificationService._internal();
  factory NotificationService() => _instance;
  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Request permissions
    await _firebaseMessaging.requestPermission();

    // 2. Setup local notifications with tap handler
    await _setupLocalNotifications();

    // 3. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle foreground messages - create local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message.data);
    });

    // 5. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateBasedOnPayload(message.data);
    });

    // 6. Check if app was opened by tapping notification (killed state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigateBasedOnPayload(initialMessage.data);
      });
    }

    // 7. Subscribe to topic and save token
    await _firebaseMessaging.subscribeToTopic('all_users');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await _saveTokenToDatabase(user.uid);

    _isInitialized = true;
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initIOS = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: initAndroid,
      iOS: initIOS,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            _navigateBasedOnPayload(Map<String, dynamic>.from(data));
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        }
      },
    );

    // Check if app was launched by tapping a local notification
    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final data = jsonDecode(payload);
          Future.delayed(const Duration(milliseconds: 1500), () {
            _navigateBasedOnPayload(Map<String, dynamic>.from(data));
          });
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }
  }

  Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    // Suppress self-notifications
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && data['uid'] == currentUser.uid) {
      return;
    }

    final type = data['type'];
    final title = data['title'] ?? 'SehatApp';
    final body = data['body'] ?? 'New notification';

    final androidDetails = AndroidNotificationDetails(
      type == 'message' ? 'message_channel' : 'post_channel',
      type == 'message' ? 'Message Notifications' : 'Post Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);
    final payload = jsonEncode(data);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    final type = data['type'];

    try {
      if (type == 'message') {
        final uid = data['otherUid'];
        final name = data['userName'];

        if (uid != null) {
          appRouter.push('/chat', extra: {'title': name ?? 'Chat', 'uid': uid});
        } else {}
      } else if (type == 'post') {
        final postDataEncoded = data['post_data'];

        if (postDataEncoded != null) {
          final postMap = postDataEncoded is String
              ? jsonDecode(postDataEncoded)
              : postDataEncoded;
          appRouter.push('/blood-request/details', extra: postMap);
        } else {}
      } else {}
    } catch (e, stack) {
      if (kDebugMode) {
        print(e);
        print(stack);
      }
    }
  }

  Future<void> _saveTokenToDatabase(String uid, {String? token}) async {
    try {
      final fcmToken = token ?? await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': fcmToken,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
