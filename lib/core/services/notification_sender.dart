import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class NotificationSender {
  // Go to Firebase Console > Project Settings > Service accounts > Generate new private key.
  static const Map<String, dynamic> _serviceAccountJson = {
    'type': 'service_account',
    'project_id': 'sehatapp-c0c8b',
    'private_key_id': '6bbe727677492df6482abcdaba9160f5ec229c11',
    'private_key':
        '-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCMpRrUSvy7Dp0U\nOQ+BVsWEF4vG6iysfupyMjKonprKdfdCSBfUfQpO9JWjFuzbLTMmP1HIH5MJP2Bm\nu4yce0Xe/Z0Y120eublBS6ODD5YsHrQ1aCPdMoYFxszKqd+HDJuSI6BNRg75Z4JF\n7WxkbQXx7UDUZ8TFxSeyPIBEKh5AJNZ1tmcff3iDukEDOSTKZXGUspSmAk5xCryP\nRMxTMcLeKhbws0/N19YWk9cXnAlnsujNx+Q1rICddpO+AYtaNJC8zsGxkHGf2i5S\n7b+OWaR8Ic45z06KSObqj9oEeGfHP/Gfcj78g1oTbi1XyxFRSQTQhbzodrjoe90p\nk6LAPiIhAgMBAAECggEAIZdDV6XLQ8/jM1PHgMAdL4XCJBGE9vPfAcQ8dipfVPCk\ny+dVDbKJlj7zSD7u9hAPEdj4qt/jqcdBunebxznn/7C55xd4n+iCtvYeSOydlM8G\ngmTrf+aTvOh0vAijculPdLFelWYgqG+Q3SuuAjRJwbTFEZXxGL0UVIz/o4gdrnrj\nJafi67xWOD2Pt4Lj2APzdVZ7KhZG5sXwJzEOCXTFS2yswP9RGo+rhnb2/ugHhir/\n5VTEd0X0XF425pXi/Iz34UUU4GpwZzBGvs6zLF5nAf3fKmoFh97bptjb8Ea1RgvZ\nGekpvQBfSspZpk10w8oO16NZT6ZtnzmGNBk8Hi2FUwKBgQDGSOYmE4zYBZzv3Gm9\nXMWgZOjQmpnSk7oV6XpQ3J33ElLS0EFogddtjBBiAMRKgtCfX5q1VnxhkKzxFZ/Z\nyA4gu6oEP2MaMBP+GbZQdxn+RCZUfVu5J6gVnJG2IeeK/pS0Gnx07h/Jac8AxUHO\nkCYndEL/f4XaHBSEXjdNj+q+twKBgQC1lTM59n5iCfrO5cFsNJrtZyKbd1ZQOlzL\nwWdAXyKhV9V20SEQ8orSNbyFeJjzcsXxNHbmPNbYGptHwjwI2f29G3OWC9yl25fO\nWj8tr2h7azeNyG/Snvbi9O4j3c/xlWKYoUqMOP4RaH4z9mQmUR9J9sgZ4/gWMOmL\nMOL9aWlN5wKBgGVs1qT1bR72yA79jOz67nAcDebenf5T6GTa9+Ey6G6AZfNF6Z8+\ng2aataqbv8xpW7OaILXPVnJFoeDz8b9hkLB3rgDcN6Imo6NfnZ1NPvOMAptHQErW\nmSjs3K/wadL0ZDY4Mh9RytqpD+TSAdZab9nQo5Czt1EY+fm3g8xd6HLDAoGAMQnZ\nKscx/IIbdPLBmNpgGMsoonnJGqOYWgKiQtUuggo5gPwbhPsrmHegsR8Pl3egk3KK\nxcUadIRC+U8wbWeJyh92yMftT/GM/tKKi2j6u5IKD8VYxbXekQ56nb8SoHiqhvPQ\nMSxXGRZyNtBM3bg8zfnSsoNJhZyyBcAvHSbxpHMCgYANx523DZ5W0akm1VbuYEX6\nEFmspj5vy2v3wAD74QbMwFJNwFMsTKCuf/nZOsnTiuQXLc8M9YfOqdEDxAL/ZF3U\nAFmEY5hp9hP0DckEcFC+g9SFNh3jNaS33gdQAmQ1930iGz68OOWR760gCq1olTrR\nVNRxOkRspztEPX/4oeUABA==\n-----END PRIVATE KEY-----\n',
    'client_email':
        'firebase-adminsdk-fbsvc@sehatapp-c0c8b.iam.gserviceaccount.com',
    'client_id': '104798695124918272817',
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': 'https://oauth2.googleapis.com/token',
    'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
    'client_x509_cert_url':
        'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40sehatapp-c0c8b.iam.gserviceaccount.com',
    'universe_domain': 'googleapis.com',
    // PASTE JSON HERE
  };

  static Future<String?> _getAccessToken() async {
    if (_serviceAccountJson.isEmpty) {
      return null;
    }
    if (!_serviceAccountJson.containsKey('project_id')) {
      debugPrint(
        '[NOTIFICATION ERROR] Service Account JSON is invalid (missing project_id).',
      );
      return null;
    }

    try {
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        _serviceAccountJson,
      );
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );
      // We can use this client directly, or just get credentials.
      // Getting access token:
      final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        scopes,
        client,
      );
      client.close(); // Close the client used for auth
      return credentials.accessToken.data;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  static Future<void> _saveNotificationToFirestore({
    required String uid,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
            'title': title,
            'subtitle': body, // Using body as subtitle/content
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'unreadCount': 0,
            'type': type,
            'payload': payload, // Save full data for navigation
          });
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  static Future<void> sendPostNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final token = await _getAccessToken();
    if (token == null) return;

    final projectId = _serviceAccountJson['project_id'];

    // Ensure data values are strings for FCM
    final stringData = data.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    // Duplicate complex objects as stringified JSON if needed
    stringData['post_data'] = jsonEncode(data);
    stringData['title'] = title;
    stringData['body'] = body;
    stringData['type'] = 'post';

    // Note: For topic messaging, we can't easily save to all users' history from client.
    // Ideally, a Cloud Function triggers on the 'posts' creation and does fan-out or users query 'posts' updates.
    // For now, only the FCM is sent.

    try {
      await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': {
            'topic': 'all_users',
            // 'notification': {'title': title, 'body': body}, // REMOVED to allow background handling (data-only)
            'data': stringData,
            'android': {
              'priority': 'high',
              // 'notification': {'channel_id': 'post_channel'}, // REMOVED
            },
          },
        }),
      );
    } catch (e) {
      debugPrint('Error sending post notification: $e');
    }
  }

  static Future<void> sendMessageNotification({
    required String toToken,
    required String toUid, // receiver uid
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    if (kDebugMode) {
      print(
        '[NotificationSender] ========== SENDING MESSAGE NOTIFICATION ==========',
      );
      print('[NotificationSender] To UID: $toUid');
      print('[NotificationSender] Title: $title');
      print('[NotificationSender] Body: $body');
    }

    // Enrich payload so background handler knows who "I" am
    final enrichedData = {...data, 'toUid': toUid};

    // 1. Save to History
    await _saveNotificationToFirestore(
      uid: toUid,
      title: title,
      body: body,
      type: 'message',
      payload: enrichedData,
    );

    if (kDebugMode) {
      print('[NotificationSender] Notification saved to Firestore history');
    }

    // 2. Send FCM
    final token = await _getAccessToken();
    if (token == null) {
      if (kDebugMode) {
        print('[NotificationSender] ✗ Failed to get access token');
      }
      return;
    }

    if (kDebugMode) {
      print('[NotificationSender] ✓ Got access token');
    }

    final projectId = _serviceAccountJson['project_id'];

    // Ensure data values are strings
    final stringData = enrichedData.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Add title and body for convenience
    stringData['title'] = title;
    stringData['body'] = body;

    final payload = {
      'message': {
        'token': toToken,
        'notification': {'title': title, 'body': body},
        'data': stringData,
        'android': {
          'priority': 'high',
          'notification': {'channel_id': 'message_channel'},
        },
      },
    };

    if (kDebugMode) {
      print('[NotificationSender] Sending FCM request...');
      print('[NotificationSender] Payload: ${jsonEncode(payload)}');
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print(
          '[NotificationSender] FCM Response Status: ${response.statusCode}',
        );
        print('[NotificationSender] FCM Response Body: ${response.body}');
        if (response.statusCode == 200) {
          print('[NotificationSender] ✓ Notification sent successfully!');
        } else {
          print('[NotificationSender] ✗ Notification failed!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[NotificationSender] ✗ Error sending message notification: $e');
      }
    }
  }
}
