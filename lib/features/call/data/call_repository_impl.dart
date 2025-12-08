import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/domain/repositories/call_repository.dart';

class CallRepository implements ICallRepository {
  CallRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  @override
  Future<String> createCall({
    required String callerUid,
    required String callerName,
    required String calleeUid,
    required String calleeName,
    required CallType type,
  }) async {
    final doc = _db.collection('calls').doc();
    await doc.set({
      'callerUid': callerUid,
      'callerName': callerName,
      'calleeUid': calleeUid,
      'calleeName': calleeName,
      'type': type.name,
      'status': CallStatus.ringing.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Stream<CallSession?> watchCall(String callId) {
    return _db.collection('calls').doc(callId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data() ?? {};
      return _toSession(snap.id, data);
    });
  }

  @override
  Future<void> setOffer({required String callId, required Map<String, dynamic> offer}) async {
    await _db.collection('calls').doc(callId).set({'offer': offer, 'status': CallStatus.ringing.name}, SetOptions(merge: true));
  }

  @override
  Future<void> setAnswer({required String callId, required Map<String, dynamic> answer}) async {
    await _db.collection('calls').doc(callId).set({'answer': answer, 'status': CallStatus.accepted.name, 'acceptedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  Future<void> addIceCandidate({required String callId, required IceCandidateModel candidate}) async {
    await _db.collection('calls').doc(callId).collection('candidates').add({
      'fromUid': candidate.fromUid,
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<IceCandidateModel> watchIceCandidates(String callId, {required String excludingUid}) {
    return _db
        .collection('calls')
        .doc(callId)
        .collection('candidates')
        .orderBy('createdAt')
        .snapshots()
        .asyncExpand((snap) async* {
          for (final d in snap.docChanges) {
            if (d.type != DocumentChangeType.added) continue;
            final data = d.doc.data() ?? {};
            final from = (data['fromUid'] ?? '') as String;
            if (from == excludingUid) continue;
            yield IceCandidateModel(
              fromUid: from,
              candidate: (data['candidate'] ?? '') as String,
              sdpMid: data['sdpMid'] as String?,
              sdpMLineIndex: (data['sdpMLineIndex'] as num?)?.toInt(),
            );
          }
        });
  }

  @override
  Future<void> updateStatus(String callId, CallStatus status, {String? reason}) async {
    await _db.collection('calls').doc(callId).set({
      'status': status.name,
      if (status == CallStatus.ended || status == CallStatus.failed) 'endedAt': FieldValue.serverTimestamp(),
      if (reason != null) 'endedReason': reason,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> endCall(String callId, {String? reason}) => updateStatus(callId, CallStatus.ended, reason: reason);

  @override
  Stream<CallSession?> watchIncomingRinging(String uid) {
    return _db
        .collection('calls')
        .where('calleeUid', isEqualTo: uid)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          final d = snap.docs.first;
          return _toSession(d.id, d.data());
        });
  }

  CallSession _toSession(String id, Map<String, dynamic> data) {
    CallStatus _parseStatus(String? s) {
      return CallStatus.values.firstWhere((v) => v.name == s, orElse: () => CallStatus.ended);
    }

    CallType _parseType(String? s) {
      return CallType.values.firstWhere((v) => v.name == s, orElse: () => CallType.audio);
    }

    return CallSession(
      id: id,
      callerUid: (data['callerUid'] ?? '') as String,
      calleeUid: (data['calleeUid'] ?? '') as String,
      callerName: (data['callerName'] ?? '') as String,
      calleeName: (data['calleeName'] ?? '') as String,
      type: _parseType(data['type'] as String?),
      status: _parseStatus(data['status'] as String?),
      offer: data['offer'] as Map<String, dynamic>?,
      answer: data['answer'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] as Timestamp?,
      acceptedAt: data['acceptedAt'] as Timestamp?,
      endedAt: data['endedAt'] as Timestamp?,
      endedReason: data['endedReason'] as String?,
    );
  }
}
