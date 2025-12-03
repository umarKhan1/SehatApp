import 'package:flutter_bloc/flutter_bloc.dart';
export '../../../bloc/validation/login_validation.dart';

class LoginValidationState {
  const LoginValidationState({
    this.email = '',
    this.password = '',
    this.isValid = false,
    this.submitting = false,
    this.error,
    this.passwordVisible = false,
  });

  final String email;
  final String password;
  final bool isValid;
  final bool submitting;
  final bool passwordVisible;
  final String? error;

  LoginValidationState copyWith({String? email, String? password, bool? isValid, bool? submitting, bool? passwordVisible, String? error}) {
    return LoginValidationState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      submitting: submitting ?? this.submitting,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      error: error,
    );
  }
}

class LoginValidationCubit extends Cubit<LoginValidationState> {
  LoginValidationCubit() : super(const LoginValidationState());

  void onEmailChanged(String value) {
    emit(state.copyWith(email: value, isValid: _validate(value, state.password)));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(password: value, isValid: _validate(state.email, value)));
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
    emit(state.copyWith(submitting: true, ));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(submitting: false));
  }
}
