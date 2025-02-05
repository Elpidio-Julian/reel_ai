import 'dart:async';
import 'package:flutter/foundation.dart';

class RecordingTimerService extends ChangeNotifier {
  Timer? _timer;
  Duration _duration = Duration.zero;
  final Duration _maxDuration;
  final VoidCallback? onMaxDurationReached;

  RecordingTimerService({
    Duration maxDuration = const Duration(minutes: 3),
    this.onMaxDurationReached,
  }) : _maxDuration = maxDuration;

  Duration get duration => _duration;
  Duration get maxDuration => _maxDuration;
  bool get isRunning => _timer?.isActive ?? false;

  void start() {
    _timer?.cancel();
    _duration = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _duration = Duration.zero;
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _duration = Duration.zero;
    notifyListeners();
  }

  void _onTick(Timer timer) {
    if (_duration >= _maxDuration) {
      stop();
      onMaxDurationReached?.call();
      return;
    }
    _duration += const Duration(seconds: 1);
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 