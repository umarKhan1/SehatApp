import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';

class CallControls extends StatelessWidget {
  const CallControls({super.key, required this.state});
  final CallState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallCubit>();
    final isVideo = state.session?.type == CallType.video;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 36.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roundButton(
              icon: state.isMuted ? Icons.mic_off : Icons.mic,
              onTap: cubit.toggleMute,
              color: Colors.white70,
            ),
            const SizedBox(width: 18),
            if (isVideo)
              _roundButton(
                icon: state.isCameraOn ? Icons.videocam : Icons.videocam_off,
                onTap: cubit.toggleCamera,
                color: Colors.white70,
              ),
            if (isVideo) ...[
              const SizedBox(width: 18),
              _roundButton(
                icon: Icons.cameraswitch,
                onTap: cubit.flipCamera,
                color: Colors.white70,
              ),
            ],
            const SizedBox(width: 18),
            _roundButton(
              icon: state.isSpeakerOn ? Icons.volume_up : Icons.hearing,
              onTap: cubit.toggleSpeaker,
              color: Colors.white70,
            ),
            const SizedBox(width: 18),
            _roundButton(
              icon: Icons.call_end,
              onTap: () => cubit.hangup(),
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: CircleAvatar(
        backgroundColor: Colors.white10,
        radius: 28,
        child: Icon(icon, color: color ?? Colors.white, size: 26),
      ),
    );
  }
}
