import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for resetting password
class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  /// Execute password reset
  ///
  /// Sends password reset email
  Future<Failure?> call(String email) async {
    return await repository.resetPassword(email);
  }
}

/// Use case for updating password
class UpdatePasswordUseCase {
  final AuthRepository repository;

  const UpdatePasswordUseCase(this.repository);

  /// Execute password update
  ///
  /// Updates the current user's password
  Future<Failure?> call(UpdatePasswordParams params) async {
    return await repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

/// Parameters for password update
class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
