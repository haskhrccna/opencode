import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out
class SignOutUseCase {

  const SignOutUseCase(this.repository);
  final AuthRepository repository;

  /// Execute sign out
  ///
  /// Clears session and local tokens
  Future<void> call() async {
    await repository.signOut();
  }
}
