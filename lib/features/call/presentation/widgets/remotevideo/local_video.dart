import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LocalVideo extends StatefulWidget {
  const LocalVideo({super.key, required this.stream, this.onFlip});
  final MediaStream stream;
  final VoidCallback? onFlip;

  @override
  State<LocalVideo> createState() => _LocalVideoState();
}

class _LocalVideoState extends State<LocalVideo> {
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
          print('[LocalVideo] Renderer initialized and stream set');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LocalVideo] Error initializing renderer: $e');
      }
    }
  }

  @override
  void didUpdateWidget(covariant LocalVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized && oldWidget.stream.id != widget.stream.id) {
      _renderer.srcObject = widget.stream;
      if (kDebugMode) {
        print('[LocalVideo] Stream updated');
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
        print('[LocalVideo] Error disposing renderer: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(
              _renderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          if (widget.onFlip != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: widget.onFlip,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
