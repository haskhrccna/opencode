import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_in_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'Password123';
    final tAuthUser = AuthUser(
      id: '123',
      email: tEmail,
      role: UserRole.student,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    test('should return AuthUser when sign in is successful', () async {
      // Arrange
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => (tAuthUser, null));

      // Act
      final (result, failure) = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, equals(tAuthUser));
      expect(failure, isNull);
      verify(() => mockRepository.signIn(email: tEmail, password: tPassword))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      final tFailure = AuthFailure.invalidCredentials();
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, isNull);
      expect(failure, equals(tFailure));
      verify(() => mockRepository.signIn(email: tEmail, password: tPassword))
          .called(1);
    });

    test('should return NetworkFailure when no connection', () async {
      // Arrange
      final tFailure = NetworkFailure.noConnection();
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<NetworkFailure>());
    });

    test('should return AuthFailure when user is disabled', () async {
      // Arrange
      final tFailure = AuthFailure.userDisabled();
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<AuthFailure>());
      expect(failure?.code, equals('user_disabled'));
    });

    test('should return AuthFailure when too many requests', () async {
      // Arrange
      final tFailure = AuthFailure.tooManyRequests();
      when(() => mockRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, isNull);
      expect(failure?.code, equals('too_many_requests'));
    });
  });
}
