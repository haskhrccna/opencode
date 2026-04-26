import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for teacher registration
class SignUpTeacherUseCase {
  final AuthRepository repository;

  const SignUpTeacherUseCase(this.repository);

  /// Execute teacher sign up
  ///
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> call(SignUpTeacherParams params) async {
    return await repository.signUpTeacher(
      email: params.email,
      password: params.password,
      arabicName: params.arabicName,
      englishName: params.englishName,
      phoneNumber: params.phoneNumber,
      bio: params.bio,
      websiteUrl: params.websiteUrl,
    );
  }
}

/// Parameters for teacher sign up
class SignUpTeacherParams {
  final String email;
  final String password;
  final String arabicName;
  final String englishName;
  final String phoneNumber;
  final String? bio;
  final String? websiteUrl;

  const SignUpTeacherParams({
    required this.email,
    required this.password,
    required this.arabicName,
    required this.englishName,
    required this.phoneNumber,
    this.bio,
    this.websiteUrl,
  });
}
