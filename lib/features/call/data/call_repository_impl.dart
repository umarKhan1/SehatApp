import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/domain/repositories/call_repository.dart';

/// Realtime Database–backed signaling.
///
/// Structure:
/// /calls/{userUid}/incoming -> {callerUid, callerName, callType, status, createdAt, sessionId}
/// /callSessions/{sessionId}/offer|answer -> SDP maps
/// /callSessions/{sessionId}/candidates/{uid}/{autoId} -> ICE candidate maps
class CallRepository implements ICallRepository {
  CallRepository({
    FirebaseDatabase? db,
    FirebaseAuth? auth,
    String? databaseUrl,
  }) : _db =
           db ??
           (() {
             final opts = FirebaseAuth.instance.app.options;
             final url = databaseUrl ?? opts.databaseURL;
             if (url != null && url.isNotEmpty) {
               return FirebaseDatabase.instanceFor(
                 app: FirebaseAuth.instance.app,
                 databaseURL: url,
               );
             }
             return FirebaseDatabase.instance;
           }());

  final FirebaseDatabase _db;

  DatabaseReference get _callsRef => _db.ref('calls');
  DatabaseReference get _sessionsRef => _db.ref('callSessions');

  @override
  Future<String> createCall({
    required String callerUid,
    required String callerName,
    required String calleeUid,
    required String calleeName,
    required CallType type,
  }) async {
    final sessionRef = _sessionsRef.push();
    final sessionId = sessionRef.key!;
    final now = ServerValue.timestamp;
    await _callsRef.child('$calleeUid/incoming').set({
      'callerUid': callerUid,
      'callerName': callerName,
      'callType': type.name,
      'status': CallStatus.ringing.name,
      'createdAt': now,
      'sessionId': sessionId,
    });
    await sessionRef.set({
      'callerUid': callerUid,
      'calleeUid': calleeUid,
      'callerName': callerName,
      'calleeName': calleeName,
      'type': type.name,
      'status': CallStatus.ringing.name,
      'createdAt': now,
    });
    return sessionId;
  }

  @override
  Stream<CallSession?> watchCall(String callId) {
    return _sessionsRef.child(callId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return _toSession(callId, data.cast<String, dynamic>());
      }
      return null;
    });
  }

  @override
  Future<CallSession?> getCall(String callId) async {
    final snap = await _sessionsRef.child(callId).get();
    final data = snap.value;
    if (data is Map) return _toSession(callId, data.cast<String, dynamic>());
    return null;
  }

  @override
  Future<void> setOffer({
    required String callId,
    required Map<String, dynamic> offer,
  }) async {
    await _sessionsRef.child(callId).update({
      'offer': offer,
      'status': CallStatus.connecting.name,
    });
  }

  @override
  Future<void> setAnswer({
    required String callId,
    required Map<String, dynamic> answer,
  }) async {
    await _sessionsRef.child(callId).update({
      'answer': answer,
      'status': CallStatus.accepted.name,
      'acceptedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> addIceCandidate({
    required String callId,
    required IceCandidateModel candidate,
  }) async {
    await _sessionsRef
        .child(callId)
        .child('candidates')
        .child(candidate.fromUid)
        .push()
        .set({
          'fromUid': candidate.fromUid,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'createdAt': ServerValue.timestamp,
        });
  }

  @override
  Stream<IceCandidateModel> watchIceCandidates(
    String callId, {
    required String excludingUid,
  }) {
    return _sessionsRef
        .child(callId)
        .child('candidates')
        .onChildAdded
        .asyncExpand((event) async* {
          final childKey = event.snapshot.key ?? '';
          if (childKey == excludingUid) return;
          final val = event.snapshot.value;
          if (val is Map) {
            final map = val.cast<String, dynamic>();
            for (final entry in map.entries) {
              final data = entry.value;
              if (data is Map) {
                yield IceCandidateModel(
                  fromUid: (data['fromUid'] ?? childKey) as String,
                  candidate: (data['candidate'] ?? '') as String,
                  sdpMid: data['sdpMid'] as String?,
                  sdpMLineIndex: (data['sdpMLineIndex'] as num?)?.toInt(),
                );
              }
            }
          }
        });
  }

  @override
  Future<void> updateStatus(
    String callId,
    CallStatus status, {
    String? reason,
  }) async {
    await _sessionsRef.child(callId).update({
      'status': status.name,
      if (status == CallStatus.ended || status == CallStatus.failed)
        'endedAt': ServerValue.timestamp,
      if (reason != null) 'endedReason': reason,
    });
  }

  @override
  Future<void> endCall(String callId, {String? reason}) async {
    await updateStatus(callId, CallStatus.ended, reason: reason);
    await _sessionsRef.child(callId).remove();
  }

  @override
  Future<void> updateIncomingStatus(String uid, CallStatus status) async {
    await _callsRef.child('$uid/incoming/status').set(status.name);
  }

  @override
  Future<void> clearIncoming(String uid) async {
    await _callsRef.child('$uid/incoming').remove();
  }

  @override
  Stream<CallSession?> watchIncomingRinging(String uid) {
    return _callsRef.child('$uid/incoming').onValue.map((event) {
      try {
        final raw = event.snapshot.value;

        // If the value is null, the incoming call was cleared
        if (raw == null) {
          if (kDebugMode) {
            print('[CallRepository] Incoming call cleared for $uid');
          }
          return null;
        }

        // Ensure we have a Map
        if (raw is! Map) {
          if (kDebugMode) {
            print(
              '[CallRepository] Invalid data type for incoming call: ${raw.runtimeType}',
            );
          }
          return null;
        }

        // Safely convert to Map<String, dynamic>
        final map = Map<String, dynamic>.from(raw);

        // Validate required fields
        final sessionId = map['sessionId'] as String?;
        final callerUid = map['callerUid'] as String?;
        final callerName = map['callerName'] as String?;
        final status = map['status'] as String?;
        final callType = map['callType'] as String?;

        // Check if all required fields are present
        if (sessionId == null || sessionId.isEmpty) {
          if (kDebugMode) {
            print('[CallRepository] Missing sessionId in incoming call data');
          }
          return null;
        }

        if (callerUid == null || callerUid.isEmpty) {
          if (kDebugMode) {
            print('[CallRepository] Missing callerUid in incoming call data');
          }
          return null;
        }

        // Only return if status is ringing
        if (status != CallStatus.ringing.name) {
          if (kDebugMode) {
            print(
              '[CallRepository] Incoming call status is not ringing: $status',
            );
          }
          return null;
        }

        // Parse createdAt timestamp
        int? createdAtMs;
        final createdAt = map['createdAt'];
        if (createdAt is num) {
          createdAtMs = createdAt.toInt();
        } else if (createdAt is String) {
          createdAtMs = int.tryParse(createdAt);
        }

        // Default to current time if createdAt is missing or invalid
        if (createdAtMs == null) {
          createdAtMs = DateTime.now().millisecondsSinceEpoch;
          if (kDebugMode) {
            print('[CallRepository] Using current time for missing createdAt');
          }
        }

        // Parse call type
        CallType type;
        try {
          type = CallType.values.firstWhere(
            (e) => e.name == (callType ?? 'audio'),
            orElse: () => CallType.audio,
          );
        } catch (e) {
          if (kDebugMode) {
            print(
              '[CallRepository] Error parsing call type: $e, defaulting to audio',
            );
          }
          type = CallType.audio;
        }

        // Create and return the session
        final session = CallSession(
          id: sessionId,
          callerUid: callerUid,
          calleeUid: uid,
          callerName: callerName ?? 'Unknown',
          calleeName: '',
          type: type,
          status: CallStatus.ringing,
          createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
        );

        if (kDebugMode) {
          print(
            '[CallRepository] Parsed incoming call: ${session.callerName} (${session.type.name})',
          );
        }
        return session;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('[CallRepository] Error parsing incoming call: $e');
          print('[CallRepository] Stack trace: $stackTrace');
        }
        return null;
      }
    });
  }

  CallSession _toSession(String id, Map<String, dynamic> data) {
    CallStatus parseStatus(String? s) => CallStatus.values.firstWhere(
      (v) => v.name == s,
      orElse: () => CallStatus.ended,
    );
    CallType parseType(String? s) => CallType.values.firstWhere(
      (v) => v.name == s,
      orElse: () => CallType.audio,
    );
    Timestamp? ts(dynamic v) =>
        v is num ? Timestamp.fromMillisecondsSinceEpoch(v.toInt()) : null;

    return CallSession(
      id: id,
      callerUid: (data['callerUid'] ?? '') as String,
      calleeUid: (data['calleeUid'] ?? '') as String,
      callerName: (data['callerName'] ?? data['callerUid'] ?? '') as String,
      calleeName: (data['calleeName'] ?? '') as String,
      type: parseType(data['type'] as String?),
      status: parseStatus(data['status'] as String?),
      offer: (data['offer'] as Map?)?.cast<String, dynamic>(),
      answer: (data['answer'] as Map?)?.cast<String, dynamic>(),
      createdAt: ts(data['createdAt']),
      acceptedAt: ts(data['acceptedAt']),
      endedAt: ts(data['endedAt']),
      endedReason: data['endedReason'] as String?,
    );
  }
}
