import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  /// Execute get current user
  ///
  /// Returns [AuthUser] if authenticated, empty user otherwise
  Future<AuthUser> call() async {
    return await repository.getCurrentUser();
  }
}

/// Use case for refreshing user data from backend
class RefreshUserUseCase {
  final AuthRepository repository;

  const RefreshUserUseCase(this.repository);

  /// Execute refresh user
  ///
  /// Useful for checking approval status updates
  Future<(AuthUser?, Failure?)> call() async {
    return await repository.refreshUser();
  }
}
