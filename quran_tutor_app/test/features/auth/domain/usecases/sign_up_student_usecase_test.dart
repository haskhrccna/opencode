import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_up_student_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpStudentUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpStudentUseCase(mockRepository);
  });

  group('SignUpStudentUseCase', () {
    const tEmail = 'student@example.com';
    const tPassword = 'Password123';
    const tArabicName = 'أحمد محمد';
    const tEnglishName = 'Ahmed Mohammed';
    final tDateOfBirth = DateTime(2010, 5, 15);
    const tPhoneNumber = '0501234567';
    const tTeacherInviteCode = 'TEAC123';
    
    final tPendingUser = AuthUser(
      id: 'student123',
      email: tEmail,
      arabicName: tArabicName,
      displayName: tEnglishName,
      role: UserRole.student,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
      phoneNumber: tPhoneNumber,
      dateOfBirth: tDateOfBirth,
    );

    test('should return AuthUser with pending status when sign up is successful', () async {
      // Arrange
      when(() => mockRepository.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenAnswer((_) async => (tPendingUser, null));

      // Act
      final (result, failure) = await useCase(
        SignUpStudentParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          dateOfBirth: tDateOfBirth,
          phoneNumber: tPhoneNumber,
          teacherInviteCode: tTeacherInviteCode,
        ),
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.isPending, isTrue);
      expect(result?.isStudent, isTrue);
      expect(result?.email, equals(tEmail));
      expect(result?.arabicName, equals(tArabicName));
      expect(failure, isNull);
    });

    test('should return AuthUser with pending status without teacher code', () async {
      // Arrange
      when(() => mockRepository.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenAnswer((_) async => (
            tPendingUser.copyWith(teacherId: null),
            null
          ));

      // Act
      final (result, failure) = await useCase(
        SignUpStudentParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          dateOfBirth: tDateOfBirth,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.isPending, isTrue);
      expect(failure, isNull);
    });

    test('should return AuthFailure when email already exists', () async {
      // Arrange
      final tFailure = AuthFailure.emailAlreadyInUse();
      when(() => mockRepository.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        SignUpStudentParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          dateOfBirth: tDateOfBirth,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, isNull);
      expect(failure?.code, equals('email_already_in_use'));
    });

    test('should return ValidationFailure when invalid invite code', () async {
      // Arrange
      final tFailure = ValidationFailure.invalidInput(message: 'Invalid invite code');
      when(() => mockRepository.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        SignUpStudentParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          dateOfBirth: tDateOfBirth,
          phoneNumber: tPhoneNumber,
          teacherInviteCode: 'INVALID',
        ),
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<ValidationFailure>());
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      final tFailure = ServerFailure.internalError();
      when(() => mockRepository.signUpStudent(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            dateOfBirth: any(named: 'dateOfBirth'),
            phoneNumber: any(named: 'phoneNumber'),
            teacherInviteCode: any(named: 'teacherInviteCode'),
          )).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        SignUpStudentParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          dateOfBirth: tDateOfBirth,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, isNull);
      expect(failure?.code, equals('internal_error'));
    });
  });
}
