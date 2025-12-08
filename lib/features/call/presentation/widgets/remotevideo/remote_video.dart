import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RemoteVideo extends StatefulWidget {
  const RemoteVideo({super.key, required this.stream});
  final MediaStream stream;

  @override
  State<RemoteVideo> createState() => _RemoteVideoState();
}

class _RemoteVideoState extends State<RemoteVideo> {
  final _renderer = RTCVideoRenderer();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  Future<void> _initializeRenderer() async {
    try {
      await _renderer.initialize();
      if (mounted) {
        setState(() {
          _renderer.srcObject = widget.stream;
          _isInitialized = true;
        });
        if (kDebugMode) {
          print('[RemoteVideo] Renderer initialized and stream set');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RemoteVideo] Error initializing renderer: $e');
      }
    }
  }

  @override
  void didUpdateWidget(covariant RemoteVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized && oldWidget.stream.id != widget.stream.id) {
      _renderer.srcObject = widget.stream;
      if (kDebugMode) {
        print('[RemoteVideo] Stream updated');
      }
    }
  }

  @override
  void dispose() {
    try {
      _renderer.srcObject = null;
      _renderer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('[RemoteVideo] Error disposing renderer: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return RTCVideoView(
      _renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}
