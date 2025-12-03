import 'package:flutter_bloc/flutter_bloc.dart';

class SignupValidationState {
  const SignupValidationState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isValid = false,
    this.submitting = false,
    this.passwordVisible = false,
    this.confirmPasswordVisible = false,
    this.error,
    this.success = false,
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isValid;
  final bool submitting;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final String? error;
  final bool success;

  SignupValidationState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isValid,
    bool? submitting,
    bool? passwordVisible,
    bool? confirmPasswordVisible,
    String? error,
    bool? success,
  }) {
    return SignupValidationState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      submitting: submitting ?? this.submitting,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmPasswordVisible: confirmPasswordVisible ?? this.confirmPasswordVisible,
      error: error,
      success: success ?? this.success,
    );
  }
}

class SignupValidationCubit extends Cubit<SignupValidationState> {
  SignupValidationCubit() : super(const SignupValidationState());

  void onNameChanged(String value) => _recalc(name: value);
  void onEmailChanged(String value) => _recalc(email: value);
  void onPasswordChanged(String value) => _recalc(password: value);
  void onConfirmPasswordChanged(String value) => _recalc(confirmPassword: value);

  void togglePasswordVisibility() => emit(state.copyWith(passwordVisible: !state.passwordVisible));
  void toggleConfirmPasswordVisibility() => emit(state.copyWith(confirmPasswordVisible: !state.confirmPasswordVisible));

  void _recalc({String? name, String? email, String? password, String? confirmPassword}) {
    final next = state.copyWith(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      success: false, // clear prior success on input change
    );
    emit(next.copyWith(isValid: _validate(next)));
  }

  bool _validate(SignupValidationState s) {
    final RegExp emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final bool emailOk = emailRx.hasMatch(s.email.trim());
    final bool nameOk = s.name.trim().isNotEmpty;
    final bool passOk = s.password.trim().length >= 6;
    final bool confirmOk = s.confirmPassword == s.password;
    return emailOk && nameOk && passOk && confirmOk;
  }

  Future<void> submit() async {
    if (!state.isValid) return;
    emit(state.copyWith(submitting: true, error: null, success: false));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(submitting: false, success: true));
  }
}
