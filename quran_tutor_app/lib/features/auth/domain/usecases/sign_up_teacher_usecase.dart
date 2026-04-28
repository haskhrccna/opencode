import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for teacher registration
class SignUpTeacherUseCase {

  const SignUpTeacherUseCase(this.repository);
  final AuthRepository repository;

  /// Execute teacher sign up
  ///
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> call(SignUpTeacherParams params) async {
    return repository.signUpTeacher(
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

  const SignUpTeacherParams({
    required this.email,
    required this.password,
    required this.arabicName,
    required this.englishName,
    required this.phoneNumber,
    this.bio,
    this.websiteUrl,
  });
  final String email;
  final String password;
  final String arabicName;
  final String englishName;
  final String phoneNumber;
  final String? bio;
  final String? websiteUrl;
}
