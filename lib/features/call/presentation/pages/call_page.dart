import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';
import 'package:sehatapp/features/call/presentation/widgets/call_control.dart';
import 'package:sehatapp/features/call/presentation/widgets/remoteaudio.dart/audio_backdrop.dart';
import 'package:sehatapp/features/call/presentation/widgets/remoteaudio.dart/remote_audio.dart';
import 'package:sehatapp/features/call/presentation/widgets/remotevideo/local_video.dart';
import 'package:sehatapp/features/call/presentation/widgets/remotevideo/remote_video.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listenWhen: (prev, next) => prev.phase != next.phase,
      listener: (context, state) {
        if (state.phase == CallPhase.ended && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<CallCubit, CallState>(
        builder: (context, state) {
          final cubit = context.read<CallCubit>();
          final session = state.session;
          final isVideo = session?.type == CallType.video;
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  if (isVideo && state.remoteStream != null)
                    RemoteVideo(stream: state.remoteStream!)
                  else
                    AudioBackdrop(state: state),
                  // Render remote audio stream even for audio calls to ensure audio plays
                  if (!isVideo && state.remoteStream != null)
                    RemoteAudio(stream: state.remoteStream!),
                  if (isVideo && state.localStream != null)
                    Positioned(
                      right: 16,
                      bottom: 100,
                      width: 120,
                      height: 180,
                      child: LocalVideo(
                        stream: state.localStream!,
                        onFlip: cubit.flipCamera,
                      ),
                    ),
                  CallControls(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



/// Widget to ensure remote audio stream is properly set up and playing
/// In WebRTC, audio tracks should play automatically, but we ensure tracks are enabled


