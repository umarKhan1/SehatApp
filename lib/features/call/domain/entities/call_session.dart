import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }
enum CallStatus { ringing, accepted, connecting, live, ended, missed, rejected, failed }

class CallSession {
  CallSession({
    required this.id,
    required this.callerUid,
    required this.calleeUid,
    required this.callerName,
    required this.calleeName,
    required this.type,
    required this.status,
    this.offer,
    this.answer,
    this.createdAt,
    this.acceptedAt,
    this.endedAt,
    this.endedReason,
  });

  final String id;
  final String callerUid;
  final String calleeUid;
  final String callerName;
  final String calleeName;
  final CallType type;
  final CallStatus status;
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;
  final Timestamp? createdAt;
  final Timestamp? acceptedAt;
  final Timestamp? endedAt;
  final String? endedReason;
}

class IceCandidateModel {
  IceCandidateModel({required this.fromUid, required this.candidate, required this.sdpMid, required this.sdpMLineIndex});
  final String fromUid;
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;
}
