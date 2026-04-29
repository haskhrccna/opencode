import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/get_current_user_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  final tUser = AuthUser(
    id: 'u-1',
    email: 'a@b.co',
    role: UserRole.student,
    status: UserStatus.approved,
    createdAt: DateTime.utc(2026, 4, 29),
  );

  group('GetCurrentUserUseCase', () {
    test('forwards to repository.getCurrentUser', () async {
      when(() => repo.getCurrentUser()).thenAnswer((_) async => tUser);
      final useCase = GetCurrentUserUseCase(repo);

      final result = await useCase();

      expect(result, tUser);
      verify(() => repo.getCurrentUser()).called(1);
    });

    test('propagates empty user when not authenticated', () async {
      final empty = AuthUser.empty();
      when(() => repo.getCurrentUser()).thenAnswer((_) async => empty);
      final useCase = GetCurrentUserUseCase(repo);

      final result = await useCase();
      expect(result.isAuthenticated, isFalse);
    });
  });

  group('RefreshUserUseCase', () {
    test('returns user on success', () async {
      when(() => repo.refreshUser()).thenAnswer((_) async => (tUser, null));
      final useCase = RefreshUserUseCase(repo);

      final (user, failure) = await useCase();

      expect(user, tUser);
      expect(failure, isNull);
    });

    test('propagates failure', () async {
      final f = AuthFailure.sessionExpired();
      when(() => repo.refreshUser()).thenAnswer((_) async => (null, f));
      final useCase = RefreshUserUseCase(repo);

      final (user, failure) = await useCase();

      expect(user, isNull);
      expect(failure, f);
    });
  });
}
