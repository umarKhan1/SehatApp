import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class CallAudioManager {
  final AudioPlayer _outgoingPlayer = AudioPlayer();
  final AudioPlayer _incomingPlayer = AudioPlayer();

  Future<void> playOutgoingRing() async {
    try {
      await _outgoingPlayer.setSource(AssetSource('ringtone/outgoing.mp3'));
      await _outgoingPlayer.setReleaseMode(ReleaseMode.loop);
      await _outgoingPlayer.resume();
    } catch (e) {
      debugPrint('Error playing outgoing ring: $e');
    }
  }

  Future<void> playIncomingRing() async {
    try {
      // Stop any existing playback first
      await _incomingPlayer.stop();

      // Set loop mode and volume before playing
      await _incomingPlayer.setReleaseMode(ReleaseMode.loop);
      await _incomingPlayer.setVolume(1.0);

      // Play custom ringtone from assets for incoming calls
      await _incomingPlayer.play(AssetSource('ringtone/outgoing.mp3'));
    } catch (e) {
      debugPrint('Error playing incoming ring: $e');
    }
  }

  Future<void> stopRings() async {
    try {
      await _outgoingPlayer.stop();
      await _incomingPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping rings: $e');
    }
  }

  void dispose() {
    _outgoingPlayer.dispose();
    _incomingPlayer.dispose();
  }
}
