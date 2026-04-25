import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  /// Execute sign in
  /// 
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> call(SignInParams params) async {
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for sign in
class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}
