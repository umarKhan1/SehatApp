import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/auth/data/auth_repository.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';

class SignupState {
  const SignupState({this.loading = false, this.error, this.uid});
  final bool loading;
  final String? error;
  final String? uid;
  SignupState copyWith({bool? loading, String? error, String? uid}) =>
      SignupState(loading: loading ?? this.loading, error: error, uid: uid ?? this.uid);
}

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required this.auth, required this.users}) : super(const SignupState());
  final AuthRepository auth;
  final UserRepository users;

  Future<void> signUp({required String name, required String email, required String password}) async {
    emit(state.copyWith(loading: true));
    try {
      final cred = await auth.signUpWithEmail(email: email, password: password);
      final uid = cred.user!.uid;
      await users.createInitialUser(uid: uid, name: name, email: email);
      emit(state.copyWith(loading: false, uid: uid));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
