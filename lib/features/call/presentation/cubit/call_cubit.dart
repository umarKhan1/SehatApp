import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/domain/repositories/call_repository.dart';

class CallState {
  const CallState({
    this.loading = false,
    this.error,
    this.session,
    this.localStream,
    this.remoteStream,
    this.isMuted = false,
    this.isCameraOn = true,
    this.isSpeakerOn = true,
    this.phase = CallPhase.idle,
  });

  final bool loading;
  final String? error;
  final CallSession? session;
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final bool isMuted;
  final bool isCameraOn;
  final bool isSpeakerOn;
  final CallPhase phase;

  CallState copyWith({
    bool? loading,
    String? error,
    CallSession? session,
    MediaStream? localStream,
    MediaStream? remoteStream,
    bool? isMuted,
    bool? isCameraOn,
    bool? isSpeakerOn,
    CallPhase? phase,
  }) {
    return CallState(
      loading: loading ?? this.loading,
      error: error,
      session: session ?? this.session,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      phase: phase ?? this.phase,
    );
  }
}

enum CallPhase { idle, outgoing, incoming, connecting, live, ended }

class CallCubit extends Cubit<CallState> {
  CallCubit(this.repo, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(const CallState());

  final ICallRepository repo;
  final FirebaseAuth _auth;

  RTCPeerConnection? _pc;
  StreamSubscription<CallSession?>? _callSub;
  StreamSubscription<IceCandidateModel>? _iceSub;
  StreamSubscription<CallSession?>? _incomingSub;

  Future<void> startOutgoing({
    required String calleeUid,
    required String calleeName,
    required CallType type,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(error: 'Not logged in'));
      return;
    }

    emit(state.copyWith(loading: true, phase: CallPhase.outgoing));
    final callId = await repo.createCall(
      callerUid: user.uid,
      callerName: user.displayName ?? 'Me',
      calleeUid: calleeUid,
      calleeName: calleeName,
      type: type,
    );
    await _initPeer(type: type, isCaller: true, callId: callId, otherUid: calleeUid);
  }

  Future<void> acceptIncoming(CallSession session) async {
    final user = _auth.currentUser;
    if (user == null) return;
    emit(state.copyWith(loading: true, session: session, phase: CallPhase.connecting));
    await _initPeer(type: session.type, isCaller: false, callId: session.id, otherUid: session.callerUid, remoteOffer: session.offer);
  }

  Future<void> rejectIncoming(CallSession session) async {
    await repo.updateStatus(session.id, CallStatus.rejected);
    emit(state.copyWith(phase: CallPhase.ended, session: session, loading: false));
  }

  Future<void> hangup({String? reason}) async {
    await _pc?.close();
    _pc = null;
    final id = state.session?.id;
    if (id != null) {
      await repo.endCall(id, reason: reason);
    }
    await _iceSub?.cancel();
    await _callSub?.cancel();
    emit(const CallState(phase: CallPhase.ended));
  }

  /// Listen for incoming ringing calls for the current user and emit incoming state.
  Future<void> startIncomingListener() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _incomingSub?.cancel();
    _incomingSub = repo.watchIncomingRinging(user.uid).listen((incoming) {
      if (incoming != null) {
        emit(state.copyWith(session: incoming, phase: CallPhase.incoming));
      }
    });
  }

  Future<void> toggleMute() async {
    final next = !state.isMuted;
    state.localStream?.getAudioTracks().forEach((t) => t.enabled = !next);
    emit(state.copyWith(isMuted: next));
  }

  Future<void> toggleCamera() async {
    final next = !state.isCameraOn;
    state.localStream?.getVideoTracks().forEach((t) => t.enabled = next);
    emit(state.copyWith(isCameraOn: next));
  }

  Future<void> toggleSpeaker() async {
    final next = !state.isSpeakerOn;
    await Helper.setSpeakerphoneOn(next);
    emit(state.copyWith(isSpeakerOn: next));
  }

  Future<void> _initPeer({
    required CallType type,
    required bool isCaller,
    required String callId,
    required String otherUid,
    Map<String, dynamic>? remoteOffer,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final config = {
      'iceServers': [
        // STUN-only for practice; add TURN here for production reliability.
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    _pc = await createPeerConnection(config);

    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': type == CallType.video ? {'facingMode': 'user'} : false,
    };
    final local = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    for (final track in local.getTracks()) {
      await _pc!.addTrack(track, local);
    }

    emit(state.copyWith(localStream: local, session: state.session));

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams.first;
        emit(state.copyWith(remoteStream: stream, phase: CallPhase.live));
      }
    };

    _pc!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        repo.addIceCandidate(
          callId: callId,
          candidate: IceCandidateModel(
            fromUid: user.uid,
            candidate: candidate.candidate!,
            sdpMid: candidate.sdpMid,
            sdpMLineIndex: candidate.sdpMLineIndex,
          ),
        );
      }
    };

    _iceSub?.cancel();
    _iceSub = repo.watchIceCandidates(callId, excludingUid: user.uid).listen((c) async {
      await _pc?.addCandidate(RTCIceCandidate(c.candidate, c.sdpMid, c.sdpMLineIndex));
    });

    if (isCaller) {
      final offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);
      await repo.setOffer(callId: callId, offer: offer.toMap());
      _listenCallUpdates(callId);
    } else {
      if (remoteOffer != null) {
        await _pc!.setRemoteDescription(RTCSessionDescription(remoteOffer['sdp'], remoteOffer['type']));
        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);
        await repo.setAnswer(callId: callId, answer: answer.toMap());
      }
      _listenCallUpdates(callId);
    }
    emit(state.copyWith(phase: isCaller ? CallPhase.outgoing : CallPhase.connecting));
  }

  void _listenCallUpdates(String callId) {
    _callSub?.cancel();
    _callSub = repo.watchCall(callId).listen((session) async {
      if (session == null) return;
      emit(state.copyWith(session: session, phase: _mapPhase(session.status)));

      if (session.answer != null && _pc?.remo == null) {
        await _pc?.setRemoteDescription(RTCSessionDescription(session.answer!['sdp'], session.answer!['type']));
      }

      if (session.status == CallStatus.ended || session.status == CallStatus.rejected || session.status == CallStatus.missed) {
        await hangup(reason: session.endedReason);
      }
    });
  }

  CallPhase _mapPhase(CallStatus status) {
    switch (status) {
      case CallStatus.ringing:
        return CallPhase.incoming;
      case CallStatus.accepted:
      case CallStatus.connecting:
        return CallPhase.connecting;
      case CallStatus.live:
        return CallPhase.live;
      case CallStatus.ended:
      case CallStatus.missed:
      case CallStatus.rejected:
      case CallStatus.failed:
        return CallPhase.ended;
    }
  }

  @override
  Future<void> close() async {
    await _callSub?.cancel();
    await _iceSub?.cancel();
    await _incomingSub?.cancel();
    await _pc?.close();
    await state.localStream?.dispose();
    await state.remoteStream?.dispose();
    return super.close();
  }
}
