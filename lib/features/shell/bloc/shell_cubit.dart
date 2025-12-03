import 'package:flutter_bloc/flutter_bloc.dart';

enum ShellTab { home, messages, more }

class ShellState {
  const ShellState({required this.index});
  final int index;
}

class ShellCubit extends Cubit<ShellState> {
  ShellCubit() : super(const ShellState(index: 0));

  void setTab(int i) => emit(ShellState(index: i));
}
