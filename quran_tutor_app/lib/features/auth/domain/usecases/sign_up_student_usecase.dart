import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for student registration
class SignUpStudentUseCase {
  final AuthRepository repository;

  const SignUpStudentUseCase(this.repository);

  /// Execute student sign up
  /// 
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> call(SignUpStudentParams params) async {
    return await repository.signUpStudent(
      email: params.email,
      password: params.password,
      arabicName: params.arabicName,
      englishName: params.englishName,
      dateOfBirth: params.dateOfBirth,
      phoneNumber: params.phoneNumber,
      teacherInviteCode: params.teacherInviteCode,
    );
  }
}

/// Parameters for student sign up
class SignUpStudentParams {
  final String email;
  final String password;
  final String arabicName;
  final String englishName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String? teacherInviteCode;

  const SignUpStudentParams({
    required this.email,
    required this.password,
    required this.arabicName,
    required this.englishName,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.teacherInviteCode,
  });
}
