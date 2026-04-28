import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_up_teacher_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpTeacherUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpTeacherUseCase(mockRepository);
  });

  group('SignUpTeacherUseCase', () {
    const tEmail = 'teacher@example.com';
    const tPassword = 'Password123';
    const tArabicName = 'محمد علي';
    const tEnglishName = 'Mohammed Ali';
    const tPhoneNumber = '0509876543';
    const tBio = 'Experienced Quran teacher';
    const tWebsiteUrl = 'https://teacher.example.com';
    
    final tPendingTeacher = AuthUser(
      id: 'teacher123',
      email: tEmail,
      arabicName: tArabicName,
      displayName: tEnglishName,
      role: UserRole.teacher,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
      phoneNumber: tPhoneNumber,
    );

    test('should return AuthUser with teacher role and pending status', () async {
      // Arrange
      when(() => mockRepository.signUpTeacher(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            phoneNumber: any(named: 'phoneNumber'),
            bio: any(named: 'bio'),
            websiteUrl: any(named: 'websiteUrl'),
          ),).thenAnswer((_) async => (tPendingTeacher, null));

      // Act
      final (result, failure) = await useCase(
        const SignUpTeacherParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          phoneNumber: tPhoneNumber,
          bio: tBio,
          websiteUrl: tWebsiteUrl,
        ),
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.isPending, isTrue);
      expect(result?.isTeacher, isTrue);
      expect(result?.isStudent, isFalse);
      expect(failure, isNull);
    });

    test('should create teacher without optional fields', () async {
      // Arrange
      when(() => mockRepository.signUpTeacher(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            phoneNumber: any(named: 'phoneNumber'),
            bio: any(named: 'bio'),
            websiteUrl: any(named: 'websiteUrl'),
          ),).thenAnswer((_) async => (tPendingTeacher, null));

      // Act
      final (result, failure) = await useCase(
        const SignUpTeacherParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, isNotNull);
      expect(result?.isTeacher, isTrue);
      expect(failure, isNull);
    });

    test('should return AuthFailure when email already exists', () async {
      // Arrange
      final tFailure = AuthFailure.emailAlreadyInUse();
      when(() => mockRepository.signUpTeacher(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            phoneNumber: any(named: 'phoneNumber'),
            bio: any(named: 'bio'),
            websiteUrl: any(named: 'websiteUrl'),
          ),).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        const SignUpTeacherParams(
          email: tEmail,
          password: tPassword,
          arabicName: tArabicName,
          englishName: tEnglishName,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, isNull);
      expect(failure, isA<AuthFailure>());
      expect(failure?.code, equals('email_already_in_use'));
    });

    test('should return ValidationFailure when weak password', () async {
      // Arrange
      final tFailure = AuthFailure.weakPassword();
      when(() => mockRepository.signUpTeacher(
            email: any(named: 'email'),
            password: any(named: 'password'),
            arabicName: any(named: 'arabicName'),
            englishName: any(named: 'englishName'),
            phoneNumber: any(named: 'phoneNumber'),
            bio: any(named: 'bio'),
            websiteUrl: any(named: 'websiteUrl'),
          ),).thenAnswer((_) async => (null, tFailure));

      // Act
      final (result, failure) = await useCase(
        const SignUpTeacherParams(
          email: tEmail,
          password: '123', // Weak password
          arabicName: tArabicName,
          englishName: tEnglishName,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, isNull);
      expect(failure?.code, equals('weak_password'));
    });
  });
}
