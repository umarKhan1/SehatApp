import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';

class AudioBackdrop extends StatelessWidget {
  const AudioBackdrop({super.key, required this.state});
  final CallState state;

  String _statusLabel() {
    switch (state.phase) {
      case CallPhase.outgoing:
        return 'Ringing...';
      case CallPhase.connecting:
        return 'Connecting...';
      case CallPhase.incoming:
        return 'Incoming call...';
      case CallPhase.ended:
        return 'Call ended';
      case CallPhase.idle:
        return '';
      case CallPhase.live:
        return _formatDuration(state.duration);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '00:00';
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
    final session = state.session;
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
