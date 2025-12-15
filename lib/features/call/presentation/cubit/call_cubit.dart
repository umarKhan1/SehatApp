import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/domain/repositories/call_repository.dart';
import 'package:sehatapp/features/call/presentation/managers/call_audio_manager.dart';
import 'package:sehatapp/features/call/presentation/managers/call_duration_manager.dart';
import 'package:sehatapp/features/call/presentation/managers/call_notification_manager.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';
import 'package:sehatapp/core/services/network_service.dart';
import 'package:sehatapp/l10n/app_localizations.dart';

/// CallState represents the current state of a call
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
    this.duration = Duration.zero,
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
  final Duration duration;

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
    Duration? duration,
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
      duration: duration ?? this.duration,
    );
  }
}

String callOutcomeTitle(CallOutcome outcome) {
  if (outcome.outcome == CallOutcomeType.missed && outcome.isIncoming) {
    return 'Missed call';
  }
  return outcome.type == CallType.video ? 'Video call' : 'Voice call';
}

String callOutcomeSubtitle(CallOutcome outcome) {
  switch (outcome.outcome) {
    case CallOutcomeType.rejected:
      return 'Declined';
    case CallOutcomeType.noAnswer:
      return 'No answer';
    case CallOutcomeType.missed:
      return outcome.isIncoming ? 'Tap to call back' : 'No answer';
    case CallOutcomeType.completed:
      return _formatOutcomeDuration(outcome.duration);
  }
}

String _formatOutcomeDuration(Duration duration) {
  if (duration.inMinutes == 0 && duration.inSeconds < 60) {
    return '${duration.inSeconds} secs';
  }
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

/// Helper to pack call outcome into a backwards-compatible message payload
Map<String, dynamic> callOutcomeMetadata(CallOutcome outcome) {
  return {
    'call': {
      'id': outcome.callId,
      'direction': outcome.isIncoming ? 'incoming' : 'outgoing',
      'type': outcome.type.name,
      'outcome': outcome.outcome.name,
      'durationSeconds': outcome.duration.inSeconds,
      'endedAt': outcome.endedAt.toIso8601String(),
    },
  };
}

/// Helper text for chat bubble bodies (safe for old clients)
String callOutcomeText(CallOutcome outcome) {
  return '${callOutcomeTitle(outcome)} • ${callOutcomeSubtitle(outcome)}';
}

enum CallPhase { idle, outgoing, incoming, connecting, live, ended }

enum CallOutcomeType { completed, noAnswer, rejected, missed }

class CallOutcome {
  CallOutcome({
    required this.callId,
    required this.isIncoming,
    required this.type,
    required this.outcome,
    required this.duration,
    required this.endedAt,
  });

  final String callId;
  final bool isIncoming;
  final CallType type;
  final CallOutcomeType outcome;
  final Duration duration;
  final DateTime endedAt;
}

/// CallCubit manages call state, WebRTC connections, and signaling
class CallCubit extends Cubit<CallState> {
  CallCubit(this.repo, {required this.chatRepo, FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(const CallState()) {
    _durationManager = CallDurationManager(
      onTick: (elapsed) {
        if (!isClosed) {
          _emitWithSideEffects(state.copyWith(duration: elapsed));
        }
      },
    );

    // Listen to auth state changes
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        // User is logged in, start listening for calls
        _startIncomingListener();
      } else {
        // User logged out, stop listening
        _incomingSub?.cancel();
        _incomingSub = null;
      }
    });

    _initNotifications();
  }

  final ICallRepository repo;
  final ChatRepository chatRepo;
  final FirebaseAuth _auth;

  final CallAudioManager _audioManager = CallAudioManager();
  late final CallDurationManager _durationManager;
  final CallNotificationManager _notificationManager =
      CallNotificationManager();
  StreamSubscription<String>? _notificationSub;

  void _initNotifications() {
    _notificationManager.init();
    _notificationSub = _notificationManager.onAction.listen((action) {
      if (isClosed) return;
      if (action == 'accept_call') {
        if (state.session != null) {
          acceptIncoming(state.session!);
        }
      } else if (action == 'decline_call') {
        if (state.session != null) {
          rejectIncoming(state.session!);
        }
      } else if (action == 'tap') {
        // App was opened from notification body, handled naturally by incoming screen check
      }
    });
  }

  RTCPeerConnection? _pc;
  StreamSubscription<CallSession?>? _callSub;
  StreamSubscription<IceCandidateModel>? _iceSub;
  StreamSubscription<CallSession?>? _incomingSub;
  StreamSubscription<User?>? _authSub;
  Timer? _ringingTimer;
  CallOutcomeType? _overrideOutcome;
  bool _hasEmittedOutcome = false;
  final _outcomeController = StreamController<CallOutcome>.broadcast();
  String? _pendingCalleeUid;

  Stream<CallOutcome> get outcomes => _outcomeController.stream;

  void _emitWithSideEffects(
    CallState newState, {
    bool skipSideEffects = false,
  }) {
    final prevPhase = state.phase;
    final prevStatus = state.session?.status;
    super.emit(newState);
    if (!skipSideEffects) {
      _handleStateChange(
        prevPhase: prevPhase,
        newPhase: newState.phase,
        prevStatus: prevStatus,
        newStatus: newState.session?.status,
      );
    }
  }

  Future<void> startOutgoing({
    required String calleeUid,
    required String calleeName,
    required CallType type,
    BuildContext? context,
  }) async {
    try {
      // Check network connectivity first
      final isConnected = await NetworkService().isConnected;
      if (!isConnected) {
        if (!isClosed) {
          _emitWithSideEffects(
            state.copyWith(
              error: 'no_internet_for_call',
              phase: CallPhase.ended,
            ),
          );
        }
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        if (!isClosed) {
          _emitWithSideEffects(
            state.copyWith(error: 'Not logged in', phase: CallPhase.ended),
          );
        }
        return;
      }

      _resetTrackingForNewCall();
      _pendingCalleeUid =
          calleeUid; // Track pending callee for fast cancellation

      final callerName = (user.displayName ?? '').trim();
      final safeCallerName = callerName.isNotEmpty
          ? callerName
          : (user.phoneNumber ?? user.email ?? 'Caller');

      try {
        await repo.clearIncoming(user.uid);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (!isClosed) {
        _emitWithSideEffects(
          state.copyWith(
            loading: true,
            phase: CallPhase.outgoing,
            duration: Duration.zero,
          ),
        );
      }

      String callId;
      try {
        callId = await repo.createCall(
          callerUid: user.uid,
          callerName: safeCallerName,
          calleeUid: calleeUid,
          calleeName: calleeName,
          type: type,
        );

        // IMMEDIATE STATE UPDATE: Store the session ID so hangup() works
        if (!isClosed) {
          final provisionalSession = CallSession(
            id: callId,
            callerUid: user.uid,
            calleeUid: calleeUid,
            callerName: safeCallerName,
            calleeName: calleeName,
            type: type,
            status: CallStatus.ringing,
            createdAt: Timestamp.now(),
          );
          _emitWithSideEffects(
            state.copyWith(
              session: provisionalSession,
              loading: false,
              phase: CallPhase.outgoing,
            ),
            skipSideEffects:
                true, // Don't trigger side effects yet, just safe storage
          );
        }
        // Keep _pendingCalleeUid until hangup() completes cleanup
      } catch (e) {
        _pendingCalleeUid = null; // Clear on creation failure
        if (!isClosed) {
          _emitWithSideEffects(
            state.copyWith(
              error: 'Failed to create call: $e',
              phase: CallPhase.ended,
              loading: false,
            ),
          );
        }
        return;
      }

      await _initPeer(
        type: type,
        isCaller: true,
        callId: callId,
        otherUid: calleeUid,
      );
    } catch (e, _) {
      _pendingCalleeUid = null;
      _emitWithSideEffects(
        state.copyWith(
          error: 'Failed to start call: $e',
          phase: CallPhase.ended,
          loading: false,
        ),
      );
    }
  }

  Future<void> acceptIncoming(CallSession session) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }

      _resetTrackingForNewCall();

      if (!isClosed) {
        _emitWithSideEffects(
          state.copyWith(
            loading: true,
            session: session,
            phase: CallPhase.connecting,
            duration: Duration.zero,
          ),
        );
      }

      try {
        await repo.updateIncomingStatus(session.calleeUid, CallStatus.accepted);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      CallSession fresh = session;
      try {
        final fetched = await repo.getCall(session.id);
        if (fetched != null) {
          fresh = fetched;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      await _initPeer(
        type: fresh.type,
        isCaller: false,
        callId: fresh.id,
        otherUid: fresh.callerUid,
        remoteOffer: fresh.offer,
      );
    } catch (e, _) {
      if (!isClosed) {
        _emitWithSideEffects(
          state.copyWith(
            error: 'Failed to accept call: $e',
            phase: CallPhase.ended,
            loading: false,
          ),
        );
      }
    }
  }

  Future<void> rejectIncoming(CallSession session) async {
    // Optimistically update UI
    if (!isClosed) {
      _emitWithSideEffects(
        state.copyWith(
          phase: CallPhase.ended,
          session: session,
          loading: false,
        ),
      );
    }

    try {
      _overrideOutcome = CallOutcomeType.rejected;
      await _notificationManager.cancel(
        session.id,
      ); // Cancel notification if user rejected

      await repo.updateStatus(session.id, CallStatus.rejected);
      await repo.clearIncoming(session.calleeUid);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // Logic already handled by optimistic update
    }
  }

  Future<void> hangup({String? reason}) async {
    try {
      if (kDebugMode) {
        print('[CallCubit] ========== HANGUP CALLED ==========');
        print('[CallCubit] Reason: $reason');
        print('[CallCubit] Current session: ${state.session?.id}');
        print('[CallCubit] Pending callee UID: $_pendingCalleeUid');
        print('[CallCubit] Current phase: ${state.phase}');
      }

      _durationManager.stop();
      _resolveOutcomeOnEnd(status: state.session?.status);
      _stopRingingTimer();

      try {
        await _pc?.close();
        _pc = null;
      } catch (e) {
        if (kDebugMode) {
          print('[CallCubit] Error closing peer connection: $e');
        }
      }

      final id = state.session?.id;
      if (id != null) {
        if (kDebugMode) {
          print('[CallCubit] Ending call session: $id');
        }
        try {
          await repo.endCall(id, reason: reason);
        } catch (e) {
          if (kDebugMode) {
            print('[CallCubit] Error ending call: $e');
          }
        }
      }

      final me = _auth.currentUser?.uid;
      final session = state.session;

      if (kDebugMode) {
        print('[CallCubit] My UID: $me');
        print('[CallCubit] Session caller: ${session?.callerUid}');
        print('[CallCubit] Session callee: ${session?.calleeUid}');
      }

      // If I am the caller, clear the callee's incoming request so they stop ringing
      String? targetCalleeUid;
      if (session != null && me != null && session.callerUid == me) {
        targetCalleeUid = session.calleeUid;
        if (kDebugMode) {
          print('[CallCubit] I am the CALLER, target callee: $targetCalleeUid');
        }
      } else if (_pendingCalleeUid != null) {
        // Fallback for fast cancellation
        targetCalleeUid = _pendingCalleeUid;
        if (kDebugMode) {
          print('[CallCubit] Using PENDING callee UID: $targetCalleeUid');
        }
      } else {
        if (kDebugMode) {
          print(
            '[CallCubit] No target callee to clear (I might be the receiver)',
          );
        }
      }

      if (targetCalleeUid != null) {
        if (kDebugMode) {
          print(
            '[CallCubit] *** CLEARING INCOMING CALL FOR: $targetCalleeUid ***',
          );
        }
        try {
          // Double-tap: Update status first to ensure listener catches it as non-ringing
          if (kDebugMode) {
            print(
              '[CallCubit] Step 1: Updating status to MISSED for $targetCalleeUid',
            );
          }
          await repo.updateIncomingStatus(targetCalleeUid, CallStatus.missed);

          if (kDebugMode) {
            print(
              '[CallCubit] Step 2: Removing incoming node for $targetCalleeUid',
            );
          }
          await repo.clearIncoming(targetCalleeUid);

          if (kDebugMode) {
            print(
              '[CallCubit] ✓ Successfully cleared incoming for $targetCalleeUid',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('[CallCubit] ✗ ERROR clearing incoming: $e');
          }
        }
      }
      _pendingCalleeUid = null;

      // Always clear my own incoming request (e.g. if I am rejecting a call)
      if (me != null) {
        if (kDebugMode) {
          print('[CallCubit] Clearing my own incoming request: $me');
        }
        try {
          await repo.updateIncomingStatus(me, CallStatus.ended);
          await repo.clearIncoming(me);
        } catch (e) {
          if (kDebugMode) {
            print('[CallCubit] Error clearing own incoming: $e');
          }
        }
      }

      await _iceSub?.cancel();
      await _callSub?.cancel();

      try {
        await state.localStream?.dispose();
        await state.remoteStream?.dispose();
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (!isClosed) {
        _emitWithSideEffects(const CallState(phase: CallPhase.ended));
      }

      if (!isClosed) {
        _emitWithSideEffects(const CallState(phase: CallPhase.ended));
      }

      await _notificationManager.cancelAll();
    } catch (e) {
      if (!isClosed) {
        _emitWithSideEffects(const CallState(phase: CallPhase.ended));
      }
    }
  }

  Future<void> _startIncomingListener() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print(
            '[CallCubit] Cannot start incoming listener - no user logged in',
          );
        }
        return;
      }

      if (kDebugMode) {
        print(
          '[CallCubit] Starting incoming call listener for UID: ${user.uid}',
        );
        print(
          '[CallCubit] User email: ${user.email}, displayName: ${user.displayName}',
        );
      }

      await _incomingSub?.cancel();

      _incomingSub = repo.watchIncomingRinging(user.uid).listen((
        incoming,
      ) async {
        if (isClosed) return;

        // Check if user is still logged in
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          if (kDebugMode) {
            print('[CallCubit] Ignoring incoming call - user not logged in');
          }
          return;
        }

        if (incoming != null) {
          if (kDebugMode) {
            print(
              '[CallCubit] Incoming call detected: ${incoming.callerName} (${incoming.id})',
            );
            print('[CallCubit] Current phase: ${state.phase}');
          }

          final isAvailablePhase =
              state.phase == CallPhase.idle ||
              state.phase == CallPhase.incoming ||
              state.phase == CallPhase.ended;

          // Only accept incoming calls if we are in an available phase (not busy)
          if (isAvailablePhase) {
            if (kDebugMode) {
              print(
                '[CallCubit] Accepting incoming call, transitioning to CallPhase.incoming',
              );
            }
            _resetTrackingForNewCall();
            if (!isClosed) {
              _emitWithSideEffects(
                state.copyWith(session: incoming, phase: CallPhase.incoming),
              );
              // Show Local Notification ONLY if app is NOT in foreground
              if (WidgetsBinding.instance.lifecycleState !=
                  AppLifecycleState.resumed) {
                await _notificationManager.showIncomingNotification(incoming);
              } else {
                if (kDebugMode) {
                  print(
                    '[CallCubit] App in foreground - suppressing call notification',
                  );
                }
              }
            }
            _startRingingTimeout(incoming, isIncoming: true);
          } else {
            if (kDebugMode) {
              print(
                '[CallCubit] Ignoring incoming call - already in ${state.phase}',
              );
            }
          }
        } else {
          // Incoming call signal removed (e.g. Sender cancelled)
          if (kDebugMode) {
            print('[CallCubit] ========== INCOMING SIGNAL REMOVED ==========');
            print('[CallCubit] Current phase: ${state.phase}');
            print('[CallCubit] Current session: ${state.session?.id}');
          }

          _stopRingingTimer();
          await _notificationManager.cancelAll();

          // Check if we need to terminate the UI
          // We end if we are in 'incoming' phase
          // OR if we are 'connecting' (accepted but not live) and we are the callee
          final isInboundConnecting =
              state.phase == CallPhase.connecting &&
              _isCurrentUserCallee(state.session);

          if (kDebugMode) {
            print('[CallCubit] Is inbound connecting: $isInboundConnecting');
            print(
              '[CallCubit] Should end UI: ${state.phase == CallPhase.incoming || isInboundConnecting}',
            );
          }

          if (state.phase == CallPhase.incoming || isInboundConnecting) {
            if (kDebugMode) {
              print(
                '[CallCubit] *** ENDING CALL PHASE DUE TO SIGNAL REMOVAL ***',
              );
            }
            if (!isClosed) {
              _emitWithSideEffects(state.copyWith(phase: CallPhase.ended));
            }
          } else {
            if (kDebugMode) {
              print('[CallCubit] Not ending - phase is ${state.phase}');
            }
          }
        }
      }, onError: (error) {});
    } catch (e) {
      // ignore
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> startIncomingListener() => _startIncomingListener();

  Future<void> toggleMute() async {
    try {
      final next = !state.isMuted;
      state.localStream?.getAudioTracks().forEach((t) => t.enabled = !next);
      if (!isClosed) {
        _emitWithSideEffects(state.copyWith(isMuted: next));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> toggleCamera() async {
    try {
      final next = !state.isCameraOn;
      state.localStream?.getVideoTracks().forEach((t) => t.enabled = next);
      if (!isClosed) {
        _emitWithSideEffects(state.copyWith(isCameraOn: next));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> flipCamera() async {
    try {
      final tracks = state.localStream?.getVideoTracks();
      final track = (tracks != null && tracks.isNotEmpty) ? tracks.first : null;
      if (track != null) {
        await Helper.switchCamera(track);
        _emitWithSideEffects(state.copyWith(localStream: state.localStream));
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CallCubit] Error flipping camera: $e');
      }
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      final next = !state.isSpeakerOn;
      await Helper.setSpeakerphoneOn(next);
      if (!isClosed) {
        _emitWithSideEffects(state.copyWith(isSpeakerOn: next));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _initPeer({
    required CallType type,
    required bool isCaller,
    required String callId,
    required String otherUid,
    Map<String, dynamic>? remoteOffer,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      _emitWithSideEffects(
        state.copyWith(error: 'Not logged in', phase: CallPhase.ended),
      );
      return;
    }

    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      };

      try {
        _pc = await createPeerConnection(config);
      } catch (e) {
        _emitWithSideEffects(
          state.copyWith(
            error: 'Failed to create connection: $e',
            phase: CallPhase.ended,
            loading: false,
          ),
        );
        return;
      }

      try {
        await Helper.setSpeakerphoneOn(state.isSpeakerOn);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': type == CallType.video
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      };

      MediaStream? local;
      try {
        local = await navigator.mediaDevices
            .getUserMedia(mediaConstraints)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Media request timed out');
              },
            );

        final audioTracks = local.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          for (final track in audioTracks) {
            track.enabled = true;
          }
        }

        if (type == CallType.video) {
          final videoTracks = local.getVideoTracks();
          if (videoTracks.isNotEmpty) {
            for (final track in videoTracks) {
              track.enabled = true;
            }
          }
        }

        if (!isClosed) {
          _emitWithSideEffects(
            state.copyWith(
              localStream: local,
              session: state.session,
              phase: isCaller ? CallPhase.outgoing : CallPhase.connecting,
              loading: false,
            ),
          );
        }
      } catch (e) {
        try {
          await _pc?.close();
          _pc = null;
        } catch (cleanupError) {
          if (kDebugMode) {
            print(e);
          }
        }
        if (kDebugMode) {
          print(e);
        }

        if (!isClosed) {
          final errorMessage =
              e.toString().contains('permission') ||
                  e.toString().contains('Permission')
              ? 'Microphone permission is required for calls'
              : 'Failed to access microphone: $e';

          _emitWithSideEffects(
            state.copyWith(
              error: errorMessage,
              phase: CallPhase.ended,
              loading: false,
            ),
          );
        }
        return;
      }

      try {
        for (final track in local.getTracks()) {
          await _pc!.addTrack(track, local);
        }
      } catch (e) {
        await local.dispose();
        await _pc?.close();
        _pc = null;
        _emitWithSideEffects(
          state.copyWith(
            error: 'Failed to add tracks: $e',
            phase: CallPhase.ended,
            loading: false,
          ),
        );
        return;
      }

      _pc!.onIceConnectionState = (iceState) {
        if (iceState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
            iceState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
          if (!isClosed) {
            if (state.session?.status != CallStatus.live) {
              repo.updateStatus(callId, CallStatus.live);
            }
            final session = state.session;
            final hasRemote = state.remoteStream != null;
            final phaseForUi =
                session != null &&
                    (session.status == CallStatus.live ||
                        session.status == CallStatus.accepted) &&
                    hasRemote
                ? CallPhase.live
                : CallPhase.connecting;
            _emitWithSideEffects(state.copyWith(phase: phaseForUi));
          }
        } else if (iceState ==
                RTCIceConnectionState.RTCIceConnectionStateFailed ||
            iceState ==
                RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          if (!isClosed && state.phase != CallPhase.ended) {
            _emitWithSideEffects(
              state.copyWith(
                error: 'Connection failed: $iceState',
                phase: CallPhase.ended,
              ),
            );
          }
        }
      };

      _pc!.onConnectionState = (connectionState) {
        if (connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          if (!isClosed && state.remoteStream != null) {
            if (state.session?.status != CallStatus.live) {
              repo.updateStatus(callId, CallStatus.live);
            }
            final session = state.session;
            final phaseForUi =
                session != null &&
                    (session.status == CallStatus.live ||
                        session.status == CallStatus.accepted)
                ? CallPhase.live
                : CallPhase.connecting;
            _emitWithSideEffects(state.copyWith(phase: phaseForUi));
          }
        }
      };

      _pc!.onTrack = (event) {
        try {
          if (event.streams.isNotEmpty) {
            final stream = event.streams.first;
            final tracks = stream.getTracks();

            for (final track in tracks) {
              if (track.kind == 'audio') {
                track.enabled = true;
              }
            }

            bool hasAudio = tracks.any((t) => t.kind == 'audio' && t.enabled);

            if (hasAudio && state.isSpeakerOn) {
              Helper.setSpeakerphoneOn(true).catchError((e) {});
            }

            if (!isClosed) {
              if (state.session?.status != CallStatus.live) {
                repo.updateStatus(callId, CallStatus.live);
              }
              final session = state.session;
              final phaseForUi =
                  session != null &&
                      (session.status == CallStatus.live ||
                          session.status == CallStatus.accepted)
                  ? CallPhase.live
                  : CallPhase.connecting;
              _emitWithSideEffects(
                state.copyWith(remoteStream: stream, phase: phaseForUi),
              );
            }
          }
        } catch (e, _) {
          if (kDebugMode) {
            print(e);
          }
        }
      };

      _pc!.onIceCandidate = (candidate) {
        try {
          if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
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
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      };

      _iceSub?.cancel();
      _iceSub = repo.watchIceCandidates(callId, excludingUid: user.uid).listen((
        c,
      ) async {
        try {
          await _pc?.addCandidate(
            RTCIceCandidate(c.candidate, c.sdpMid, c.sdpMLineIndex),
          );
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }, onError: (error) {});

      if (isCaller) {
        try {
          final offer = await _pc!.createOffer();
          await _pc!.setLocalDescription(offer);
          await repo.setOffer(callId: callId, offer: offer.toMap());
          _listenCallUpdates(callId);
        } catch (e) {
          await local.dispose();
          await _pc?.close();
          _pc = null;
          _emitWithSideEffects(
            state.copyWith(
              error: 'Failed to create offer: $e',
              phase: CallPhase.ended,
              loading: false,
            ),
          );
          return;
        }
      } else {
        if (remoteOffer != null && remoteOffer['sdp'] != null) {
          try {
            await _pc!.setRemoteDescription(
              RTCSessionDescription(remoteOffer['sdp'], remoteOffer['type']),
            );

            final answer = await _pc!.createAnswer();

            await _pc!.setLocalDescription(answer);

            final answerMap = answer.toMap();
            await repo.setAnswer(callId: callId, answer: answerMap);

            _listenCallUpdates(callId);
          } catch (e) {
            await local.dispose();
            await _pc?.close();
            _pc = null;
            if (!isClosed) {
              _emitWithSideEffects(
                state.copyWith(
                  error: 'Failed to create answer: $e',
                  phase: CallPhase.ended,
                  loading: false,
                ),
              );
            }
            return;
          }
        } else {
          _listenCallUpdates(callId);
        }
      }

      _startConnectionCheck(callId);
    } catch (e) {
      if (!isClosed) {
        _emitWithSideEffects(
          state.copyWith(
            error: 'Failed to initialize call: $e',
            phase: CallPhase.ended,
            loading: false,
          ),
        );
      }
    }
  }

  void _startConnectionCheck(String callId) {
    int checkCount = 0;
    const maxChecks = 30;

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isClosed || _pc == null) {
        timer.cancel();
        return;
      }

      checkCount++;
      if (checkCount > maxChecks) {
        timer.cancel();
        return;
      }

      try {
        if (state.remoteStream != null && state.phase != CallPhase.live) {
          if (!isClosed) {
            final session = state.session;
            final phaseForUi =
                session != null && session.status == CallStatus.live
                ? CallPhase.live
                : CallPhase.connecting;
            _emitWithSideEffects(state.copyWith(phase: phaseForUi));
          }
          if (state.session?.status == CallStatus.live) {
            timer.cancel();
          }
          return;
        }

        try {
          final receivers = await _pc!.getReceivers();
          bool hasRemoteTrack = receivers.any(
            (r) => r.track != null && r.track!.kind != null,
          );

          if (hasRemoteTrack && state.remoteStream == null) {
            for (final receiver in receivers) {
              if (receiver.track != null) {
                final track = receiver.track!;

                if (track.kind == 'audio') {
                  track.enabled = true;
                }

                final stream = await createLocalMediaStream('remote-stream');
                await stream.addTrack(track);

                for (final audioTrack in stream.getAudioTracks()) {
                  audioTrack.enabled = true;
                }

                if (!isClosed) {
                  final session = state.session;
                  final phaseForUi =
                      session != null && session.status == CallStatus.live
                      ? CallPhase.live
                      : CallPhase.connecting;
                  _emitWithSideEffects(
                    state.copyWith(remoteStream: stream, phase: phaseForUi),
                  );

                  if (track.kind == 'audio') {
                    Helper.setSpeakerphoneOn(true).catchError((e) {});
                  }

                  if (session != null && session.status == CallStatus.live) {
                    timer.cancel();
                  }
                  return;
                }
              }
            }
          } else if (hasRemoteTrack && state.phase != CallPhase.live) {
            if (!isClosed) {
              final session = state.session;
              final phaseForUi =
                  session != null && session.status == CallStatus.live
                  ? CallPhase.live
                  : CallPhase.connecting;
              _emitWithSideEffects(state.copyWith(phase: phaseForUi));
            }
            if (state.session?.status == CallStatus.live) {
              timer.cancel();
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  void _listenCallUpdates(String callId) {
    _callSub?.cancel();
    _callSub = repo.watchCall(callId).listen((session) async {
      if (isClosed) return;
      if (session == null) {
        // Session removed, call ended remotely
        await hangup(reason: 'ended');
        return;
      }

      if (!isClosed) {
        final phase = _mapPhaseForSession(session);
        _emitWithSideEffects(state.copyWith(session: session, phase: phase));
      }

      try {
        if (session.answer != null && session.answer!['sdp'] != null) {
          final remote = await _pc?.getRemoteDescription();
          if (remote == null) {
            await _pc?.setRemoteDescription(
              RTCSessionDescription(
                session.answer!['sdp'],
                session.answer!['type'],
              ),
            );
          }
        }

        if (session.offer != null &&
            session.offer!['sdp'] != null &&
            _pc != null) {
          final local = await _pc?.getLocalDescription();
          if (local == null) {
            try {
              await _pc?.setRemoteDescription(
                RTCSessionDescription(
                  session.offer!['sdp'],
                  session.offer!['type'],
                ),
              );

              final answer = await _pc?.createAnswer();
              if (answer != null) {
                await _pc?.setLocalDescription(answer);
                await repo.setAnswer(
                  callId: session.id,
                  answer: answer.toMap(),
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (session.status == CallStatus.ended ||
          session.status == CallStatus.rejected ||
          session.status == CallStatus.missed) {
        await hangup(reason: session.endedReason);
      }
    }, onError: (error) {});
  }

  void _handleStateChange({
    required CallPhase prevPhase,
    required CallPhase newPhase,
    required CallStatus? prevStatus,
    required CallStatus? newStatus,
  }) {
    final session = state.session;
    final isIncoming = _isCurrentUserCallee(session);
    final wasLive =
        state.phase == CallPhase.live ||
        (state.duration > Duration.zero) ||
        (_durationManager.liveStartAt != null);

    if (newStatus != prevStatus) {
      if (newStatus == CallStatus.ringing && session != null) {
        _startRingingTimeout(session, isIncoming: isIncoming);
      }

      if (newStatus == CallStatus.accepted || newStatus == CallStatus.live) {
        _stopRingingTimer();
      }

      if (_isTerminalStatus(newStatus)) {
        _stopRingingTimer();
        _audioManager.stopRings();
        _durationManager.stop(resetStart: true);
        _resolveOutcomeOnEnd(status: newStatus);
      }
    }

    // Audio Logic
    if (newPhase == CallPhase.outgoing && prevPhase != CallPhase.outgoing) {
      _audioManager.playOutgoingRing();
    } else if (newPhase == CallPhase.incoming &&
        prevPhase != CallPhase.incoming) {
      // Play system ringtone for incoming calls
      _audioManager.playIncomingRing();
    } else if (newPhase == CallPhase.live ||
        newPhase == CallPhase.ended ||
        newPhase == CallPhase.connecting) {
      if (prevPhase == CallPhase.outgoing || prevPhase == CallPhase.incoming) {
        _audioManager.stopRings();
      }
    }

    final wentLive =
        newStatus == CallStatus.live && prevStatus != CallStatus.live;
    if (wentLive) {
      _stopRingingTimer();
      _durationManager.start(null);
    }

    if (newPhase == CallPhase.ended && prevPhase != CallPhase.ended) {
      _stopRingingTimer();
      if (wasLive) {
        _durationManager.stop();
      } else {
        _emitWithSideEffects(
          state.copyWith(duration: Duration.zero),
          skipSideEffects: true,
        );
      }
      _durationManager.stop(resetStart: true);
      _resolveOutcomeOnEnd(status: newStatus);
    }
  }

  void _startRingingTimeout(CallSession session, {required bool isIncoming}) {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(const Duration(seconds: 30), () async {
      if (isClosed) return;
      if (state.session?.id == session.id &&
          state.session?.status == CallStatus.ringing) {
        if (state.phase == CallPhase.outgoing ||
            state.phase == CallPhase.incoming) {
          if (isIncoming) {
            await repo.updateStatus(session.id, CallStatus.missed);
            await repo.clearIncoming(session.calleeUid);
            _overrideOutcome = CallOutcomeType.missed;
          } else {
            await repo.updateStatus(session.id, CallStatus.missed);
            await repo.clearIncoming(session.calleeUid);
            _overrideOutcome = CallOutcomeType.noAnswer;
          }
          await hangup(reason: 'timeout');
        }
      }
    });
  }

  void _stopRingingTimer() {
    _ringingTimer?.cancel();
    _ringingTimer = null;
  }

  bool _isTerminalStatus(CallStatus? status) {
    return status == CallStatus.ended ||
        status == CallStatus.rejected ||
        status == CallStatus.missed ||
        status == CallStatus.failed;
  }

  bool _isCurrentUserCallee(CallSession? session) {
    if (session == null) return false;
    final user = _auth.currentUser;
    return user != null && session.calleeUid == user.uid;
  }

  void _resetTrackingForNewCall() {
    _stopRingingTimer();
    _durationManager.stop(resetStart: true);
    _overrideOutcome = null;
    _hasEmittedOutcome = false;
    if (!isClosed) {
      _emitWithSideEffects(
        state.copyWith(duration: Duration.zero),
        skipSideEffects: true,
      );
    }
  }

  void _resolveOutcomeOnEnd({CallStatus? status}) {
    if (_hasEmittedOutcome) return;
    final session = state.session;
    if (session == null) return;

    final bool isIncoming = _isCurrentUserCallee(session);
    final bool wasLive =
        (_durationManager.liveStartAt != null) ||
        state.duration > Duration.zero;

    CallOutcomeType type = CallOutcomeType.noAnswer;
    if (wasLive) {
      type = CallOutcomeType.completed;
    } else if (_overrideOutcome != null) {
      type = _overrideOutcome!;
    } else if (status == CallStatus.rejected) {
      type = CallOutcomeType.rejected;
    } else if (status == CallStatus.missed) {
      type = CallOutcomeType.missed;
    } else if (isIncoming) {
      type = CallOutcomeType.missed;
    }

    _recordOutcome(type);
  }

  void _recordOutcome(CallOutcomeType type, {Duration? durationOverride}) {
    if (_hasEmittedOutcome || _outcomeController.isClosed) return;
    final session = state.session;
    if (session == null) return;

    _hasEmittedOutcome = true;
    final isIncoming = _isCurrentUserCallee(session);
    final duration = durationOverride ?? state.duration;
    final outcome = CallOutcome(
      callId: session.id,
      isIncoming: isIncoming,
      type: session.type,
      outcome: type,
      duration: duration,
      endedAt: DateTime.now(),
    );

    try {
      _outcomeController.add(outcome);
    } catch (e) {
      // already closed
    }

    chatRepo.sendMessage(
      conversationId: ChatRepository.conversationId(
        session.callerUid,
        session.calleeUid,
      ),
      fromUid: session.callerUid,
      toUid: session.calleeUid,
      text: callOutcomeText(outcome),
      type: 'call_log',
      metadata: callOutcomeMetadata(outcome),
    );
  }

  CallPhase _mapPhaseForSession(CallSession session) {
    switch (session.status) {
      case CallStatus.ringing:
        return _isCurrentUserCallee(session)
            ? CallPhase.incoming
            : CallPhase.outgoing;
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
    _stopRingingTimer();
    _durationManager.stop(resetStart: true);
    await _callSub?.cancel();
    await _iceSub?.cancel();
    await _incomingSub?.cancel();
    await _authSub?.cancel();
    await _pc?.close();
    try {
      await state.localStream?.dispose();
      await state.remoteStream?.dispose();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _audioManager
      ..stopRings()
      ..dispose();
    await _notificationSub?.cancel();
    await _outcomeController.close();
    return super.close();
  }
}
