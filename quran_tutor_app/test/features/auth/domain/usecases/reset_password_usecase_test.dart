import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/reset_password_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  group('ResetPasswordUseCase', () {
    test('returns null on success', () async {
      when(() => repo.resetPassword(any())).thenAnswer((_) async => null);
      final useCase = ResetPasswordUseCase(repo);

      final failure = await useCase('a@b.co');

      expect(failure, isNull);
      verify(() => repo.resetPassword('a@b.co')).called(1);
    });

    test('forwards failure', () async {
      final f = AuthFailure.userNotFound();
      when(() => repo.resetPassword(any())).thenAnswer((_) async => f);
      final useCase = ResetPasswordUseCase(repo);

      final failure = await useCase('missing@x.io');
      expect(failure, f);
    });
  });

  group('UpdatePasswordUseCase', () {
    test('returns null on success and forwards both passwords', () async {
      when(
        () => repo.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => null);
      final useCase = UpdatePasswordUseCase(repo);

      final failure = await useCase(
        const UpdatePasswordParams(
          currentPassword: 'old',
          newPassword: 'newSecret123',
        ),
      );

      expect(failure, isNull);
      verify(
        () => repo.updatePassword(
          currentPassword: 'old',
          newPassword: 'newSecret123',
        ),
      ).called(1);
    });

    test('propagates failure', () async {
      final f = AuthFailure.weakPassword();
      when(
        () => repo.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => f);
      final useCase = UpdatePasswordUseCase(repo);

      final failure = await useCase(
        const UpdatePasswordParams(currentPassword: 'old', newPassword: 'x'),
      );
      expect(failure, f);
    });
  });
}
