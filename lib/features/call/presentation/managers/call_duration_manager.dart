import 'dart:async';

class CallDurationManager {
  CallDurationManager({required this.onTick});

  final void Function(Duration elapsed) onTick;
  Timer? _durationTimer;
  DateTime? _liveStartAt;

  DateTime? get liveStartAt => _liveStartAt;

  void start(Duration? initialDuration) {
    if (_liveStartAt == null) {
      _liveStartAt = DateTime.now();
      // If resuming, we might need to adjust start time based on initialDuration
      // But for now keeping it simple as per original logic
      onTick(Duration.zero);
    }

    _durationTimer?.cancel();
    _updateDurationNow();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDurationNow();
    });
  }

  void stop({bool resetStart = false}) {
    _durationTimer?.cancel();
    _durationTimer = null;
    if (resetStart) {
      _liveStartAt = null;
    }
  }

  void _updateDurationNow() {
    if (_liveStartAt == null) return;
    final elapsed = DateTime.now().difference(_liveStartAt!);
    if (elapsed.isNegative) return;
    onTick(elapsed);
  }
}
