import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quran_tutor_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quran_tutor_app/features/auth/data/models/user_model.dart';
import 'package:quran_tutor_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getCurrentUser', () {
    final tUserModel = UserModel(
      id: '123',
      email: 'test@example.com',
      role: 'student',
      status: 'approved',
      createdAt: DateTime.now(),
    );

    test('should return cached user when available', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => tUserModel.toSupabaseJson());

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.email, equals('test@example.com'));
      verify(() => mockLocalDataSource.getUserData()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return remote user when no cache', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.email, equals('test@example.com'));
      verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
    });

    test('should return empty user when not authenticated', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => null);
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isAuthenticated, isFalse);
    });
  });

  group('signIn', () {
    const tEmail = 'test@example.com';
    const tPassword = 'Password123';
    final tUserModel = UserModel(
      id: '123',
      email: tEmail,
      role: 'student',
      status: 'approved',
      createdAt: DateTime.now(),
    );

    test('should return AuthUser on successful sign in', () async {
      // Arrange
      when(() => mockRemoteDataSource.signIn(any(), any()))
          .thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      final (result, failure) = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.email, equals(tEmail));
      expect(failure, isNull);
      verify(() => mockLocalDataSource.cacheUserData(any())).called(1);
    });

    test('should return AuthFailure on invalid credentials', () async {
      // Arrange
      when(() => mockRemoteDataSource.signIn(any(), any()))
          .thenThrow(AuthException.invalidCredentials());

      // Act
      final (result, failure) = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<AuthFailure>());
      expect(failure?.code, equals('invalid_credentials'));
    });

    test('should return NetworkFailure on network error', () async {
      // Arrange
      when(() => mockRemoteDataSource.signIn(any(), any()))
          .thenThrow(NetworkException.noConnection());

      // Act
      final (result, failure) = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<NetworkFailure>());
    });
  });

  group('signUpStudent', () {
    const tEmail = 'student@example.com';
    const tPassword = 'Password123';
    const tArabicName = 'أحمد';
    const tEnglishName = 'Ahmed';
    final tDateOfBirth = DateTime(2010, 5, 15);
    const tPhoneNumber = '0501234567';

    final tPendingUser = UserModel(
      id: 'student123',
      email: tEmail,
      arabicName: tArabicName,
      displayName: tEnglishName,
      role: 'student',
      status: 'pending',
      createdAt: DateTime.now(),
    );

    test('should return pending AuthUser on successful sign up', () async {
      // Arrange
      when(() => mockRemoteDataSource.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenAnswer((_) async => tPendingUser);
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      final (result, failure) = await repository.signUpStudent(
        email: tEmail,
        password: tPassword,
        arabicName: tArabicName,
        englishName: tEnglishName,
        dateOfBirth: tDateOfBirth,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.isPending, isTrue);
      expect(result?.isStudent, isTrue);
      expect(failure, isNull);
    });

    test('should return AuthFailure when email already exists', () async {
      // Arrange
      when(() => mockRemoteDataSource.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenThrow(AuthException.emailAlreadyInUse());

      // Act
      final (result, failure) = await repository.signUpStudent(
        email: tEmail,
        password: tPassword,
        arabicName: tArabicName,
        englishName: tEnglishName,
        dateOfBirth: tDateOfBirth,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result, isNull);
      expect(failure?.code, equals('email_already_in_use'));
    });

    test('should return ValidationFailure on invalid invite code', () async {
      // Arrange
      when(() => mockRemoteDataSource.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenThrow(ValidationException.invalidInput(message: 'Invalid code'));

      // Act
      final (result, failure) = await repository.signUpStudent(
        email: tEmail,
        password: tPassword,
        arabicName: tArabicName,
        englishName: tEnglishName,
        dateOfBirth: tDateOfBirth,
        phoneNumber: tPhoneNumber,
        teacherInviteCode: 'INVALID',
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<ValidationFailure>());
    });
  });

  group('signOut', () {
    test('should clear local data and sign out from remote', () async {
      // Arrange
      when(() => mockRemoteDataSource.signOut())
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.clearAll())
          .thenAnswer((_) async {});

      // Act
      await repository.signOut();

      // Assert
      verify(() => mockRemoteDataSource.signOut()).called(1);
      verify(() => mockLocalDataSource.clearAll()).called(1);
    });
  });

  group('resetPassword', () {
    const tEmail = 'test@example.com';

    test('should return null on successful reset', () async {
      // Arrange
      when(() => mockRemoteDataSource.resetPassword(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.resetPassword(tEmail);

      // Assert
      expect(result, isNull);
    });

    test('should return AuthFailure on user not found', () async {
      // Arrange
      when(() => mockRemoteDataSource.resetPassword(any()))
          .thenThrow(AuthException.userNotFound());

      // Act
      final result = await repository.resetPassword(tEmail);

      // Assert
      expect(result, isA<AuthFailure>());
    });
  });

  group('authStateChanges', () {
    final tUserModel = UserModel(
      id: '123',
      email: 'test@example.com',
      role: 'student',
      status: 'approved',
      createdAt: DateTime.now(),
    );

    test('should emit AuthUser on auth state changes', () async {
      // Arrange
      when(() => mockRemoteDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(tUserModel));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      final stream = repository.authStateChanges;

      // Assert
      await expectLater(
        stream,
        emits(isA<AuthUser>()),
      );
    });

    test('should emit empty AuthUser on sign out', () async {
      // Arrange
      when(() => mockRemoteDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      when(() => mockLocalDataSource.clearAll())
          .thenAnswer((_) async {});

      // Act
      final stream = repository.authStateChanges;

      // Assert
      await expectLater(
        stream,
        emits(isA<AuthUser>().having((u) => u.isAuthenticated, 'isAuthenticated', false)),
      );
    });
  });

  group('refreshUser', () {
    final tUserModel = UserModel(
      id: '123',
      email: 'test@example.com',
      role: 'student',
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final tApprovedUser = UserModel(
      id: '123',
      email: 'test@example.com',
      role: 'student',
      status: 'approved',
      createdAt: DateTime.now(),
    );

    test('should return updated user when approved', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);
      when(() => mockRemoteDataSource.refreshUser(any()))
          .thenAnswer((_) async => tApprovedUser);
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      final (result, failure) = await repository.refreshUser();

      // Assert
      expect(result, isNotNull);
      expect(result?.isApproved, isTrue);
      expect(failure, isNull);
    });

    test('should return AuthFailure when not authenticated', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      final (result, failure) = await repository.refreshUser();

      // Assert
      expect(result?.isAuthenticated, isFalse);
    });
  });
}
