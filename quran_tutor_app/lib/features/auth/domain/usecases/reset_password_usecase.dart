import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for resetting password
class ResetPasswordUseCase {

  const ResetPasswordUseCase(this.repository);
  final AuthRepository repository;

  /// Execute password reset
  ///
  /// Sends password reset email
  Future<Failure?> call(String email) async {
    return repository.resetPassword(email);
  }
}

/// Use case for updating password
class UpdatePasswordUseCase {

  const UpdatePasswordUseCase(this.repository);
  final AuthRepository repository;

  /// Execute password update
  ///
  /// Updates the current user's password
  Future<Failure?> call(UpdatePasswordParams params) async {
    return repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

/// Parameters for password update
class UpdatePasswordParams {

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;
}
