import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_up_student_usecase.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_up_teacher_usecase.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpStudentUseCase extends Mock implements SignUpStudentUseCase {}

class MockSignUpTeacherUseCase extends Mock implements SignUpTeacherUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockRefreshUserUseCase extends Mock implements RefreshUserUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpStudentUseCase mockSignUpStudentUseCase;
  late MockSignUpTeacherUseCase mockSignUpTeacherUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockRefreshUserUseCase mockRefreshUserUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;

  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
    registerFallbackValue(SignUpStudentParams(
      email: '',
      password: '',
      arabicName: '',
      englishName: '',
      dateOfBirth: DateTime.now(),
      phoneNumber: '',
    ));
    registerFallbackValue(const SignUpTeacherParams(
      email: '',
      password: '',
      arabicName: '',
      englishName: '',
      phoneNumber: '',
    ));
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpStudentUseCase = MockSignUpStudentUseCase();
    mockSignUpTeacherUseCase = MockSignUpTeacherUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockRefreshUserUseCase = MockRefreshUserUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();

    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    authBloc = AuthBloc(
      authRepository: mockRepository,
      signInUseCase: mockSignInUseCase,
      signUpStudentUseCase: mockSignUpStudentUseCase,
      signUpTeacherUseCase: mockSignUpTeacherUseCase,
      signOutUseCase: mockSignOutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      refreshUserUseCase: mockRefreshUserUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AppStarted', () {
    final tAuthUser = AuthUser(
      id: '123',
      email: 'test@example.com',
      role: UserRole.student,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when user is authenticated',
      build: () {
        when(() => mockGetCurrentUserUseCase())
            .thenAnswer((_) async => tAuthUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when user is not authenticated',
      build: () {
        when(() => mockGetCurrentUserUseCase())
            .thenAnswer((_) async => AuthUser.empty());
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PendingApproval] when user is pending',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => AuthUser(
            id: '123',
            email: 'test@example.com',
            role: UserRole.student,
            status: UserStatus.pending,
            createdAt: DateTime.now(),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<PendingApproval>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Rejected] when user is rejected',
      build: () {
        when(() => mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => AuthUser(
            id: '123',
            email: 'test@example.com',
            role: UserRole.student,
            status: UserStatus.rejected,
            createdAt: DateTime.now(),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Rejected>(),
      ],
    );
  });

  group('SignInRequested', () {
    const tEmail = 'test@example.com';
    const tPassword = 'Password123';
    final tAuthUser = AuthUser(
      id: '123',
      email: tEmail,
      role: UserRole.student,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when sign in succeeds',
      build: () {
        when(() => mockSignInUseCase(any()))
            .thenAnswer((_) async => (tAuthUser, null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequested(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when sign in fails',
      build: () {
        when(() => mockSignInUseCase(any())).thenAnswer(
            (_) async => (null, AuthFailure.invalidCredentials()));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequested(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailureState>(),
      ],
    );
  });

  group('SignUpStudentRequested', () {
    final tDateOfBirth = DateTime(2010, 5, 15);
    final tPendingUser = AuthUser(
      id: 'student123',
      email: 'student@example.com',
      role: UserRole.student,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PendingApproval] when sign up succeeds',
      build: () {
        when(() => mockSignUpStudentUseCase(any()))
            .thenAnswer((_) async => (tPendingUser, null));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignUpStudentRequested(
        email: 'student@example.com',
        password: 'Password123',
        arabicName: 'أحمد',
        englishName: 'Ahmed',
        dateOfBirth: tDateOfBirth,
        phoneNumber: '0501234567',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<PendingApproval>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when sign up fails',
      build: () {
        when(() => mockSignUpStudentUseCase(any())).thenAnswer(
            (_) async => (null, AuthFailure.emailAlreadyInUse()));
        return authBloc;
      },
      act: (bloc) => bloc.add(SignUpStudentRequested(
        email: 'student@example.com',
        password: 'Password123',
        arabicName: 'أحمد',
        englishName: 'Ahmed',
        dateOfBirth: tDateOfBirth,
        phoneNumber: '0501234567',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailureState>(),
      ],
    );
  });

  group('SignUpTeacherRequested', () {
    final tPendingTeacher = AuthUser(
      id: 'teacher123',
      email: 'teacher@example.com',
      role: UserRole.teacher,
      status: UserStatus.pending,
      createdAt: DateTime.now(),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PendingApproval] when teacher sign up succeeds',
      build: () {
        when(() => mockSignUpTeacherUseCase(any()))
            .thenAnswer((_) async => (tPendingTeacher, null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignUpTeacherRequested(
        email: 'teacher@example.com',
        password: 'Password123',
        arabicName: 'محمد',
        englishName: 'Mohammed',
        phoneNumber: '0509876543',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<PendingApproval>(),
      ],
    );
  });

  group('SignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when sign out succeeds',
      build: () {
        when(() => mockSignOutUseCase()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ],
    );
  });

  group('RefreshUserRequested', () {
    final tAuthUser = AuthUser(
      id: '123',
      email: 'test@example.com',
      role: UserRole.student,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when user is approved after refresh',
      build: () {
        when(() => mockRefreshUserUseCase())
            .thenAnswer((_) async => (tAuthUser, null));
        return authBloc;
      },
      seed: () => PendingApproval(userId: '123', email: 'test@example.com'),
      act: (bloc) => bloc.add(const RefreshUserRequested()),
      expect: () => [
        isA<Authenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Rejected] when user is rejected after refresh',
      build: () {
        when(() => mockRefreshUserUseCase()).thenAnswer(
          (_) async => (
            tAuthUser.copyWith(status: UserStatus.rejected),
            null
          ),
        );
        return authBloc;
      },
      seed: () => const PendingApproval(userId: '123', email: 'test@example.com'),
      act: (bloc) => bloc.add(const RefreshUserRequested()),
      expect: () => [
        isA<Rejected>(),
      ],
    );
  });
}
