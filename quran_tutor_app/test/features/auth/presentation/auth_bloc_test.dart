import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;

  setUp(() async {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.getCurrentUser()).thenAnswer(
      (_) async => AuthUser(
        id: '123',
        email: 'test@example.com',
        role: UserRole.student,
        status: UserStatus.approved,
        createdAt: DateTime.now(),
      ),
    );
    authBloc = AuthBloc(mockRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AppStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading then authenticated when user exists',
      build: () => authBloc,
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );
  });

  group('SignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading then authenticated on success',
      build: () {
        final tAuthUser = AuthUser(
          id: '123',
          email: 'test@example.com',
          role: UserRole.student,
          status: UserStatus.approved,
          createdAt: DateTime.now(),
        );
        when(() => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),).thenAnswer(
          (_) async => (tAuthUser, null),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequested(email: 'test@example.com', password: 'password')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );
  });

  group('SignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading then unauthenticated on sign out',
      build: () {
        when(() => mockRepository.signOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );
  });

  group('ResetPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading then unauthenticated on success '
      '(regression: previously emitted nothing on success)',
      build: () {
        when(() => mockRepository.resetPassword(any()))
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const ResetPasswordRequested(email: 'test@example.com')),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );
  });

  group('UpdatePasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading then resting state on success '
      '(regression: previously emitted nothing on success)',
      build: () {
        when(() => mockRepository.updatePassword(
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            ),).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const UpdatePasswordRequested(
        currentPassword: 'old',
        newPassword: 'new',
      ),),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having(
              (s) => s.status,
              'status',
              AuthStatus.authenticated,
            )
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );
  });
}
