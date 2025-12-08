import 'package:sehatapp/features/call/domain/entities/call_session.dart';

abstract class ICallRepository {
  Future<String> createCall({
    required String callerUid,
    required String callerName,
    required String calleeUid,
    required String calleeName,
    required CallType type,
  });

  Stream<CallSession?> watchCall(String callId);

  Future<void> setOffer({
    required String callId,
    required Map<String, dynamic> offer,
  });
  Future<void> setAnswer({
    required String callId,
    required Map<String, dynamic> answer,
  });
  Future<void> addIceCandidate({
    required String callId,
    required IceCandidateModel candidate,
  });

  Stream<IceCandidateModel> watchIceCandidates(
    String callId, {
    required String excludingUid,
  });

  Future<void> updateStatus(String callId, CallStatus status, {String? reason});
  Future<void> endCall(String callId, {String? reason});

  /// Stream the latest incoming ringing call for the given user.
  Stream<CallSession?> watchIncomingRinging(String uid);

  /// Fetch a call session once (used after accept to get current payload).
  Future<CallSession?> getCall(String callId);

  /// Update the incoming status for a user (e.g., accepted/rejected/ended).
  Future<void> updateIncomingStatus(String uid, CallStatus status);
  Future<void> clearIncoming(String uid);
}
