import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sehatapp/features/auth/bloc/validation/login_validation.dart';
import 'package:sehatapp/features/auth/data/auth_repository.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late LoginValidationCubit cubit;
  late MockAuthRepository mockAuth;
  late MockUserRepository mockUsers;

  setUp(() {
    mockAuth = MockAuthRepository();
    mockUsers = MockUserRepository();
    cubit = LoginValidationCubit(auth: mockAuth, users: mockUsers);
  });

  tearDown(() {
    cubit.close();
  });

  group('LoginValidationCubit', () {
    test('initial state has empty email and password', () {
      expect(cubit.state.email, '');
      expect(cubit.state.password, '');
      expect(cubit.state.isValid, isFalse);
    });

    test('valid email and password makes form valid', () {
      cubit
        ..onEmailChanged('test@example.com')
        ..onPasswordChanged('password123');
      expect(cubit.state.isValid, isTrue);
    });

    test('invalid email makes form invalid', () {
      cubit
        ..onEmailChanged('invalid-email')
        ..onPasswordChanged('password123');
      expect(cubit.state.isValid, isFalse);
    });

    test('short password makes form invalid', () {
      cubit
        ..onEmailChanged('test@example.com')
        ..onPasswordChanged('123');
      expect(cubit.state.isValid, isFalse);
    });

    test('empty email makes form invalid', () {
      cubit
        ..onEmailChanged('')
        ..onPasswordChanged('password123');
      expect(cubit.state.isValid, isFalse);
    });

    test('togglePasswordVisibility changes visibility state', () {
      expect(cubit.state.passwordVisible, isFalse);
      cubit.togglePasswordVisibility();
      expect(cubit.state.passwordVisible, isTrue);
      cubit.togglePasswordVisibility();
      expect(cubit.state.passwordVisible, isFalse);
    });
  });
}
