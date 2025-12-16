import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/auth/bloc/signup/signup_cubit.dart';
import 'package:sehatapp/features/auth/bloc/validation/signup_validation_cubit.dart';

class MockSignupCubit extends Mock implements SignupCubit {}

void main() {
  late SignupValidationCubit cubit;
  late MockSignupCubit mockSignupCubit;

  setUp(() {
    mockSignupCubit = MockSignupCubit();
    cubit = SignupValidationCubit(mockSignupCubit);
  });

  tearDown(() {
    cubit.close();
  });

  group('SignupValidationCubit', () {
    test('initial state has empty fields and is invalid', () {
      expect(cubit.state.name, '');
      expect(cubit.state.email, '');
      expect(cubit.state.password, '');
      expect(cubit.state.confirmPassword, '');
      expect(cubit.state.isValid, isFalse);
    });

    test('invalid email makes form invalid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('invalid');
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('password123');
      expect(cubit.state.isValid, isFalse);
    });

    test('valid email with all other fields valid makes form valid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('password123');
      expect(cubit.state.isValid, isTrue);
    });

    test('password less than 6 characters makes form invalid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('12345');
      cubit.onConfirmPasswordChanged('12345');
      expect(cubit.state.isValid, isFalse);
    });

    test('password with 6 or more characters makes form valid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('123456');
      cubit.onConfirmPasswordChanged('123456');
      expect(cubit.state.isValid, isTrue);
    });

    test('empty name makes form invalid', () {
      cubit.onNameChanged('');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('password123');
      expect(cubit.state.isValid, isFalse);
    });

    test('non-empty name with all other fields valid makes form valid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('password123');
      expect(cubit.state.isValid, isTrue);
    });

    test('mismatched passwords make form invalid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('different');
      expect(cubit.state.isValid, isFalse);
    });

    test('matching passwords with all other fields valid makes form valid', () {
      cubit.onNameChanged('John Doe');
      cubit.onEmailChanged('valid@email.com');
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('password123');
      expect(cubit.state.isValid, isTrue);
    });

    test('togglePasswordVisibility changes visibility state', () {
      expect(cubit.state.passwordVisible, isFalse);
      cubit.togglePasswordVisibility();
      expect(cubit.state.passwordVisible, isTrue);
      cubit.togglePasswordVisibility();
      expect(cubit.state.passwordVisible, isFalse);
    });

    test('toggleConfirmPasswordVisibility changes visibility state', () {
      expect(cubit.state.confirmPasswordVisible, isFalse);
      cubit.toggleConfirmPasswordVisibility();
      expect(cubit.state.confirmPasswordVisible, isTrue);
      cubit.toggleConfirmPasswordVisibility();
      expect(cubit.state.confirmPasswordVisible, isFalse);
    });
  });
}
