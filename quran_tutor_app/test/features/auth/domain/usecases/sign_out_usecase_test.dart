import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/usecases/sign_out_usecase.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUp(() {
    repo = _MockAuthRepository();
  });

  group('SignOutUseCase', () {
    test('calls repository.signOut exactly once', () async {
      when(() => repo.signOut()).thenAnswer((_) async {});
      final useCase = SignOutUseCase(repo);

      await useCase();

      verify(() => repo.signOut()).called(1);
    });

    test('propagates errors thrown by the repository', () async {
      when(() => repo.signOut()).thenThrow(Exception('boom'));
      final useCase = SignOutUseCase(repo);

      expect(useCase.call, throwsException);
    });
  });
}
