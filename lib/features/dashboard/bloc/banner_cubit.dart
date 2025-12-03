import 'package:flutter_bloc/flutter_bloc.dart';

class BannerState {
  const BannerState({required this.index});
  final int index;
}

class BannerCubit extends Cubit<BannerState> {
  BannerCubit() : super(const BannerState(index: 0));
  void setIndex(int i) => emit(BannerState(index: i));
}
