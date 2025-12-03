import 'package:flutter_bloc/flutter_bloc.dart';

sealed class OnboardingState {
  const OnboardingState({required this.pageIndex, required this.isLast});
  final int pageIndex;
  final bool isLast;
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial() : super(pageIndex: 0, isLast: false);
}

class OnboardingUpdated extends OnboardingState {
  const OnboardingUpdated({required super.pageIndex, required super.isLast});
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingInitial());

  void setPage(int index, int total) {
    emit(OnboardingUpdated(pageIndex: index, isLast: index == total - 1));
  }
}
