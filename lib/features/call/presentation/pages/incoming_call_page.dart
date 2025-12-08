import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';

class IncomingCallPage extends StatelessWidget {
  const IncomingCallPage({super.key, required this.session});
  final CallSession session;

  @override
  Widget build(BuildContext context) {
    final isVideo = session.type == CallType.video;
    final callerLabel = session.callerName.isNotEmpty
        ? session.callerName
        : session.callerUid;
    return BlocListener<CallCubit, CallState>(
      listenWhen: (prev, next) => prev.phase != next.phase,
      listener: (context, state) {
        if (kDebugMode) {
          print('[IncomingCallPage] Phase changed: ${state.phase}');
        }

        // Only pop when transitioning to connecting/live (call accepted)
        // or when call is explicitly ended
        if (state.phase == CallPhase.connecting ||
            state.phase == CallPhase.live) {
          if (kDebugMode) {
            print('[IncomingCallPage] Call accepted, popping incoming screen');
          }
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state.phase == CallPhase.ended) {
          if (kDebugMode) {
            print('[IncomingCallPage] Call ended, popping incoming screen');
          }
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
        // Don't pop for other phase changes - keep the incoming call screen visible
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey.shade800,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  callerLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isVideo ? 'Video call' : 'Voice call',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'decline',
                        backgroundColor: Colors.redAccent,
                        onPressed: () =>
                            context.read<CallCubit>().rejectIncoming(session),
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'accept',
                        backgroundColor: Colors.green,
                        onPressed: () =>
                            context.read<CallCubit>().acceptIncoming(session),
                        child: Icon(
                          isVideo ? Icons.videocam : Icons.call,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
