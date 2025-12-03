import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SplashState {}
class SplashVisible extends SplashState {}
class SplashFadingIn extends SplashState {}
class SplashFinished extends SplashState {}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashVisible());

  Future<void> start() async {
    // Fade in over 2s, then finish and navigate.
    emit(SplashFadingIn());
    await Future<void>.delayed(const Duration(seconds: 2));
    emit(SplashFinished());
  }
}
