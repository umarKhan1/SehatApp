import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';

class AudioBackdrop extends StatefulWidget {
  const AudioBackdrop({super.key, required this.state});
  final CallState state;

  @override
  State<AudioBackdrop> createState() => AudioBackdropState();
}

class AudioBackdropState extends State<AudioBackdrop> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _liveStart;

  @override
  void initState() {
    super.initState();
    _syncTimerWithPhase(widget.state);
  }

  @override
  void didUpdateWidget(covariant AudioBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.phase != widget.state.phase ||
        oldWidget.state.session?.acceptedAt !=
            widget.state.session?.acceptedAt) {
      _syncTimerWithPhase(widget.state);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimerWithPhase(CallState state) {
    final status = state.session?.status;
    final acceptedAt = state.session?.acceptedAt?.toDate();
    final isLive = status == CallStatus.live || state.phase == CallPhase.live;

    if (isLive) {
      _startTimer(acceptedAt ?? DateTime.now());
    } else {
      _stopTimer(reset: true);
    }
  }

  void _startTimer(DateTime startTime) {
    _timer?.cancel();
    _liveStart = startTime;
    _elapsed = _safeDiff(DateTime.now(), startTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _liveStart == null) return;
      setState(() {
        _elapsed = _safeDiff(DateTime.now(), _liveStart!);
      });
    });

    setState(() {});
  }

  void _stopTimer({bool reset = false}) {
    _timer?.cancel();
    _timer = null;

    if (reset && (_elapsed != Duration.zero || _liveStart != null)) {
      setState(() {
        _elapsed = Duration.zero;
        _liveStart = null;
      });
    }
  }

  Duration _safeDiff(DateTime now, DateTime start) {
    final diff = now.difference(start);
    return diff.isNegative ? Duration.zero : diff;
  }

  String _statusLabel() {
    if (_liveStart != null) {
      return _formatDuration(_elapsed);
    }

    switch (widget.state.phase) {
      case CallPhase.outgoing:
      case CallPhase.connecting:
        return 'Ringing...';
      case CallPhase.incoming:
        return 'Incoming...';
      case CallPhase.ended:
        return 'Ended';
      case CallPhase.idle:
        return '';
      case CallPhase.live:
        return '00:00';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    String name = '';
    final session = widget.state.session;
    if (session != null) {
      final myUid = FirebaseAuth.instance.currentUser?.uid;
      final isCaller = session.callerUid == myUid;
      name = isCaller ? session.calleeName : session.callerName;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.person, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 16),
          Text(
            name.isNotEmpty ? name : 'Calling...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusLabel(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
