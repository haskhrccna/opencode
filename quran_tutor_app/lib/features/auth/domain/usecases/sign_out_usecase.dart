import '../repositories/auth_repository.dart';

/// Use case for signing out
class SignOutUseCase {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  /// Execute sign out
  ///
  /// Clears session and local tokens
  Future<void> call() async {
    await repository.signOut();
  }
}
