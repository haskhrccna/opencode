import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInUseCase {

  const SignInUseCase(this.repository);
  final AuthRepository repository;

  /// Execute sign in
  /// 
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> call(SignInParams params) async {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for sign in
class SignInParams {

  const SignInParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}
