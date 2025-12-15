import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/services/network_service.dart';

/// States for network connectivity
sealed class NetworkStatus {}

class NetworkConnected extends NetworkStatus {}

class NetworkDisconnected extends NetworkStatus {}

class NetworkChecking extends NetworkStatus {}

/// Cubit to manage global network status
class NetworkStatusCubit extends Cubit<NetworkStatus> {
  NetworkStatusCubit(this._networkService) : super(NetworkChecking()) {
    _init();
  }

  final NetworkService _networkService;
  StreamSubscription<bool>? _subscription;

  void _init() {
    _subscription = _networkService.connectivityStream.listen((isConnected) {
      if (isConnected) {
        emit(NetworkConnected());
      } else {
        emit(NetworkDisconnected());
      }
    });
  }

  /// Manually check connectivity and retry
  Future<void> retry() async {
    emit(NetworkChecking());
    await Future.delayed(const Duration(milliseconds: 500));
    final isConnected = await _networkService.isConnected;
    if (isConnected) {
      emit(NetworkConnected());
    } else {
      emit(NetworkDisconnected());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
