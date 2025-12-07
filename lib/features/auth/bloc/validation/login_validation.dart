import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/auth/data/auth_repository.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';
import 'package:sehatapp/features/auth/models/user_model.dart';

class LoginValidationState {
  const LoginValidationState({
    this.email = '',
    this.password = '',
    this.isValid = false,
    this.submitting = false,
    this.error,
    this.passwordVisible = false,
    this.success = false,
    this.nextRouteName,
  });

  final String email;
  final String password;
  final bool isValid;
  final bool submitting;
  final bool passwordVisible;
  final String? error;
  final bool success;
  final String? nextRouteName;

  LoginValidationState copyWith({String? email, String? password, bool? isValid, bool? submitting, bool? passwordVisible, String? error, bool? success, String? nextRouteName}) {
    return LoginValidationState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      submitting: submitting ?? this.submitting,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      error: error,
      success: success ?? this.success,
      nextRouteName: nextRouteName ?? this.nextRouteName,
    );
  }
}

class LoginValidationCubit extends Cubit<LoginValidationState> {
  LoginValidationCubit({required this.auth, required this.users}) : super(const LoginValidationState());

  final AuthRepository auth;
  final IUserRepository users;

  void onEmailChanged(String value) {
    emit(state.copyWith(email: value, isValid: _validate(value, state.password), success: false));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(password: value, isValid: _validate(state.email, value), success: false));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(passwordVisible: !state.passwordVisible));
  }

  bool _validate(String email, String password) {
    final RegExp emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final bool emailOk = emailRx.hasMatch(email.trim());
    final bool passOk = password.trim().length >= 6;
    return emailOk && passOk;
  }

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(submitting: true, success: false));
    try {
      final cred = await auth.signInWithEmail(email: state.email.trim(), password: state.password.trim());
      final uid = cred.user!.uid;
      final UserModel? user = await users.getUser(uid);
      final bool profileCompleted = user?.profileCompleted ?? false;
      // Fallback to step based on profileCompleted if needed
      final int step = profileCompleted ? 3 : 1;
      String route;
      if (profileCompleted || step >= 3) {
        route = 'shell';
      } else if (step == 2) {
        route = 'profileSetupStep2';
      } else {
        route = 'profileSetupStep1';
      }
      emit(state.copyWith(submitting: false, success: true, nextRouteName: route));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString(), success: false));
    }
  }
}
