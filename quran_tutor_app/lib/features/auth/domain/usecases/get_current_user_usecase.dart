import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  /// Execute get current user
  ///
  /// Returns [AuthUser] if authenticated, empty user otherwise
  Future<AuthUser> call() async {
    return repository.getCurrentUser();
  }
}

/// Use case for refreshing user data from backend
class RefreshUserUseCase {
  const RefreshUserUseCase(this.repository);
  final AuthRepository repository;

  /// Execute refresh user
  ///
  /// Useful for checking approval status updates
  Future<(AuthUser?, Failure?)> call() async {
    return repository.refreshUser();
  }
}
