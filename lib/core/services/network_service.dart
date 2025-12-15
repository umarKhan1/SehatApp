import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class NetworkService {
  NetworkService._internal();
  factory NetworkService() => _instance;
  static final NetworkService _instance = NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _controller;

  /// Stream of network connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectivityStream {
    _controller ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = _isConnected(results);
      _controller?.add(isConnected);
    });

    // Emit initial status
    _checkInitialConnectivity();
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final isConnected = _isConnected(results);
    _controller?.add(isConnected);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  /// Check current connectivity status
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  void dispose() {
    _subscription?.cancel();
    _controller?.close();
  }
}
