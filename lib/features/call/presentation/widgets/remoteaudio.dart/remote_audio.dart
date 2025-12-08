import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RemoteAudio extends StatefulWidget {
  const RemoteAudio({super.key, required this.stream});
  final MediaStream stream;

  @override
  State<RemoteAudio> createState() => _RemoteAudioState();
}

class _RemoteAudioState extends State<RemoteAudio> {
  final _renderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _initRenderer();
    _ensureAudioEnabled();
    // Periodically check to ensure audio stays enabled
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _ensureAudioEnabled();
    });
  }

  Future<void> _initRenderer() async {
    try {
      await _renderer.initialize();
      // Ensure audio plays at full volume
      _renderer.setVolume(1.0);
      if (!mounted) return;
      setState(() {
        _renderer.srcObject = widget.stream;
        _isRendererInitialized = true;
      });
      if (kDebugMode) {
        print('[RemoteAudio] Renderer initialized and stream attached');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RemoteAudio] Error initializing audio renderer: $e');
      }
    }
  }

  void _ensureAudioEnabled() {
    try {
      if (!mounted) return;

      // Get all audio tracks and ensure they're enabled
      final audioTracks = widget.stream.getAudioTracks();

      bool anyChanged = false;
      for (final track in audioTracks) {
        if (!track.enabled) {
          track.enabled = true;
          anyChanged = true;
          if (kDebugMode) {
            print('[RemoteAudio] Re-enabled audio track: ${track.id}');
          }
        }

        // Also check if track is muted; some platforms may not implement this
        try {
          final isMuted = track.muted ?? false;
          if (isMuted) {
            if (kDebugMode) {
              print('[RemoteAudio] Warning: Audio track ${track.id} is muted');
            }
          }
        } catch (_) {
          // Ignore unimplemented properties on some platforms
        }
      }

      if (anyChanged) {
        if (kDebugMode) {
          print('[RemoteAudio] Re-enabled ${audioTracks.length} audio tracks');
        }
      }

      // Verify stream is active
      final isActive = widget.stream.active;
      if (isActive == false) {
        if (kDebugMode) {
          print('[RemoteAudio] Warning: Stream is not active');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RemoteAudio] Error ensuring audio enabled: $e');
      }
    }
  }

  @override
  void didUpdateWidget(covariant RemoteAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream.id != widget.stream.id) {
      if (_isRendererInitialized) {
        _renderer.srcObject = widget.stream;
      }
      _ensureAudioEnabled();
      if (kDebugMode) {
        print('[RemoteAudio] Stream updated, re-checking audio');
      }
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    try {
      _renderer.srcObject = null;
      _renderer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('[RemoteAudio] Error disposing audio renderer: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRendererInitialized) return const SizedBox.shrink();
    // Hidden view keeps audio renderer alive so remote audio plays
    return SizedBox(width: 1, height: 1, child: RTCVideoView(_renderer));
  }
}
