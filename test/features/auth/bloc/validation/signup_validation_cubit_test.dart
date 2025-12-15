import 'package:flutter_test/flutter_test.dart';
import 'package:sehatapp/features/auth/bloc/validation/signup_validation_cubit.dart';

void main() {
  late SignupValidationCubit cubit;

  setUp(() {
    cubit = SignupValidationCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('SignupValidationCubit', () {
    test('email validation regex', () {
      cubit.onEmailChanged('invalid');
      expect(cubit.state.isEmailValid, isFalse);

      cubit.onEmailChanged('valid@email.com');
      expect(cubit.state.isEmailValid, isTrue);
    });

    test('password minimum 6 characters', () {
      cubit.onPasswordChanged('12345');
      expect(cubit.state.isPasswordValid, isFalse);

      cubit.onPasswordChanged('123456');
      expect(cubit.state.isPasswordValid, isTrue);
    });

    test('name not empty', () {
      cubit.onNameChanged('');
      expect(cubit.state.isNameValid, isFalse);

      cubit.onNameChanged('John Doe');
      expect(cubit.state.isNameValid, isTrue);
    });

    test('passwords must match', () {
      cubit.onPasswordChanged('password123');
      cubit.onConfirmPasswordChanged('different');
      expect(cubit.state.doPasswordsMatch, isFalse);

      cubit.onConfirmPasswordChanged('password123');
      expect(cubit.state.doPasswordsMatch, isTrue);
    });
  });
}
