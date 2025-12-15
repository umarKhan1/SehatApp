import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sehatapp/core/services/notification_sender.dart';

class ConversationSummary {
  ConversationSummary({
    required this.id,
    required this.otherUid,
    required this.otherName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.otherTyping,
  });
  final String id;
  final String otherUid;
  final String otherName;
  final String lastMessage;
  final Timestamp? lastMessageAt;
  final int unreadCount;
  final bool otherTyping;
}

class MessageItem {
  MessageItem({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.text,
    required this.createdAt,
    required this.status,
    this.reactions = const {},
    this.replyToMessageId,
    this.replyPreviewText,
    this.type,
    this.metadata,
  });
  final String id;
  final String fromUid;
  final String toUid;
  final String text;
  final Timestamp createdAt;
  final String status; // sent|delivered|read|deleted
  // Optional extras
  final Map<String, String> reactions; // uid -> emoji
  final String? replyToMessageId;
  final String? replyPreviewText;
  final String? type;
  final Map<String, dynamic>? metadata;
}

class ChatRepository {
  ChatRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  static String conversationId(String a, String b) {
    final s = [a, b]..sort();
    return '${s[0]}_${s[1]}';
  }

  Future<String> getOrCreateConversation({
    required String a,
    required String b,
    String? aName,
    String? bName,
  }) async {
    final id = conversationId(a, b);
    final ref = _db.collection('conversations').doc(id);

    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participants': [a, b],
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unread': {a: 0, b: 0},
        'typing': {a: false, b: false},
        'names': {a: aName ?? '', b: bName ?? ''},
      });
    }
    return id;
  }

  Stream<List<ConversationSummary>> streamInbox(String uid) {
    // Avoid composite index requirement by not using orderBy; sort client-side.
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final items =
              snap.docs.map((d) {
                final data = d.data();
                final parts = (data['participants'] as List).cast<String>();
                final otherUid = parts.firstWhere(
                  (p) => p != uid,
                  orElse: () => uid,
                );
                final names = (data['names'] ?? {}) as Map<String, dynamic>;
                final unread = (data['unread'] ?? {}) as Map<String, dynamic>;
                final typing = (data['typing'] ?? {}) as Map<String, dynamic>;
                return ConversationSummary(
                  id: d.id,
                  otherUid: otherUid,
                  otherName: (names[otherUid] ?? '') as String,
                  lastMessage: (data['lastMessage'] ?? '') as String,
                  lastMessageAt: data['lastMessageAt'] as Timestamp?,
                  unreadCount: ((unread[uid] ?? 0) as num).toInt(),
                  otherTyping: (typing[otherUid] ?? false) as bool,
                );
              }).toList()..sort((a, b) {
                final ta = a.lastMessageAt?.toDate();
                final tb = b.lastMessageAt?.toDate();
                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;
                return tb.compareTo(ta);
              });
          return items;
        });
  }

  Stream<List<MessageItem>> streamMessages(
    String conversationId, {
    int? limit,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true);
    if (limit != null) {
      q = q.limit(limit);
    }
    return q.snapshots(includeMetadataChanges: true).map((snap) {
      final items = snap.docs
          .map((d) {
            final data = d.data();
            final reactions = _parseReactions(data);
            if (reactions.isNotEmpty) {}
            return MessageItem(
              id: d.id,
              fromUid: (data['fromUid'] ?? '') as String,
              toUid: (data['toUid'] ?? '') as String,
              text: (data['text'] ?? '') as String,
              createdAt: (data['createdAt'] ?? Timestamp.now()) as Timestamp,
              status: (data['status'] ?? 'sent') as String,
              reactions: reactions,
              replyToMessageId: (data['replyToMessageId']) as String?,
              replyPreviewText: (data['replyPreviewText']) as String?,
              type: (data['type']) as String?,
              metadata: (data['metadata'] as Map<String, dynamic>?),
            );
          })
          .toList()
          .reversed
          .toList();
      return items;
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamConversation(
    String conversationId,
  ) {
    return _db.collection('conversations').doc(conversationId).snapshots();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String fromUid,
    required String toUid,
    required String text,
    String? replyToMessageId,
    String? replyPreviewText,
    String? type,
    Map<String, dynamic>? metadata,
  }) async {
    if (kDebugMode) {
      print('[ChatRepository] ========== SENDING MESSAGE ==========');
      print('[ChatRepository] From: $fromUid');
      print('[ChatRepository] To: $toUid');
      print('[ChatRepository] Text: $text');
    }

    final msgRef = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();
    final batch = _db.batch()
      ..set(msgRef, {
        'fromUid': fromUid,
        'toUid': toUid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'sent',
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (replyPreviewText != null) 'replyPreviewText': replyPreviewText,
        if (type != null) 'type': type,
        if (metadata != null) 'metadata': metadata,
      });
    final convRef = _db.collection('conversations').doc(conversationId);
    batch.update(convRef, {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread.$toUid': FieldValue.increment(1),
    });
    await batch.commit();

    if (kDebugMode) {
      print('[ChatRepository] Message saved to Firestore');
      print('[ChatRepository] Fetching FCM token for recipient: $toUid');
    }

    // Send notification asynchronously without blocking the UI
    _sendNotificationAsync(toUid, fromUid, text, conversationId);
  }

  void _sendNotificationAsync(
    String toUid,
    String fromUid,
    String text,
    String conversationId,
  ) async {
    try {
      // Add timeout to prevent blocking for too long (3 seconds max)
      await Future.any([
        _performNotificationSend(toUid, fromUid, text, conversationId),
        Future.delayed(const Duration(seconds: 3)),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('[ChatRepository]  ERROR in notification async: $e');
      }
    }
  }

  Future<void> _performNotificationSend(
    String toUid,
    String fromUid,
    String text,
    String conversationId,
  ) async {
    final toUserDoc = await _db.collection('users').doc(toUid).get();
    final token = toUserDoc.data()?['fcmToken'];
    if (kDebugMode) {
      if (token == null) {
        print('[ChatRepository] ✗ WARNING: No FCM token found for user $toUid');
        print('[ChatRepository] User data: ${toUserDoc.data()}');
      } else {
        print('[ChatRepository] ✓ Found FCM token for user $toUid');
        print(
          '[ChatRepository] Token: ${token.toString().substring(0, 20)}...',
        );
      }
    }

    final fromUserDoc = await _db.collection('users').doc(fromUid).get();
    final senderName = fromUserDoc.data()?['name'] ?? 'New Message';

    if (kDebugMode) {
      print('[ChatRepository] Sender name: $senderName');
    }

    if (token != null) {
      if (kDebugMode) {
        print(
          '[ChatRepository] Calling NotificationSender.sendMessageNotification...',
        );
      }
      NotificationSender.sendMessageNotification(
        toToken: token,
        toUid: toUid,
        title: senderName,
        body: text,
        data: {
          'type': 'message',
          'conversationId': conversationId,
          'otherUid': fromUid,
          'userName': senderName,
        },
      );
      if (kDebugMode) {
        print('[ChatRepository] ✓ Notification request sent');
      }
    } else {
      if (kDebugMode) {
        print('[ChatRepository] ✗ Skipping notification - no token');
      }
    }
  }

  Future<void> reactToMessage({
    required String conversationId,
    required String messageId,
    String? emoji,
    required String userUid,
  }) async {
    final ref = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);
    if (emoji == null || emoji.isEmpty) {
      await ref.set({
        'reactions.$userUid': FieldValue.delete(),
      }, SetOptions(merge: true));
    } else {
      await ref.set({'reactions.$userUid': emoji}, SetOptions(merge: true));
    }
  }

  static Map<String, String> _parseReactions(Map<String, dynamic> data) {
    final result = <String, String>{};
    // Handle flattened reactions fields
    data.forEach((key, value) {
      if (key.startsWith('reactions.') &&
          value != null &&
          value.toString().trim().isNotEmpty) {
        final uid = key.substring('reactions.'.length);
        result[uid] = value.toString();
      }
    });
    // Also handle nested reactions map if present
    final raw = data['reactions'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (key is String &&
            value != null &&
            value.toString().trim().isNotEmpty) {
          result[key] = value.toString();
        }
      });
    }
    final legacy = data['reaction'];
    if (legacy != null && legacy.toString().trim().isNotEmpty) {
      result['legacy'] = legacy.toString();
    }
    return result;
  }

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
    required String requesterUid,
  }) async {
    final ref = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);
    await ref.set({'status': 'deleted', 'text': ''}, SetOptions(merge: true));
  }

  Future<void> reportMessage({
    required String conversationId,
    required String messageId,
    required String reason,
  }) async {
    final ref = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);
    await ref.set({
      'reported': true,
      'reportReason': reason,
      'reportedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markRead({
    required String conversationId,
    required String readerUid,
  }) async {
    final convRef = _db.collection('conversations').doc(conversationId);
    await convRef.update({
      'unread.$readerUid': 0,
      'lastReadAt.$readerUid': FieldValue.serverTimestamp(),
    });
    // Avoid composite index by removing orderBy; just fetch recent non-read messages for this reader
    final q = convRef
        .collection('messages')
        .where('toUid', isEqualTo: readerUid)
        .where('status', whereIn: ['sent', 'delivered']);
    final msgs = await q.get();
    if (msgs.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in msgs.docs) {
      batch.update(d.reference, {'status': 'read'});
    }
    await batch.commit();
  }

  Future<void> setTyping({
    required String conversationId,
    required String uid,
    required bool typing,
  }) async {
    await _db.collection('conversations').doc(conversationId).update({
      'typing.$uid': typing,
    });
  }
}
