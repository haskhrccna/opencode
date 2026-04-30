import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for student registration
class SignUpStudentUseCase {
  const SignUpStudentUseCase(this.repository);
  final AuthRepository repository;

  /// Execute student sign up
  ///
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> call(SignUpStudentParams params) async {
    return repository.signUpStudent(
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
  const SignUpStudentParams({
    required this.email,
    required this.password,
    required this.arabicName,
    required this.englishName,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.teacherInviteCode,
  });
  final String email;
  final String password;
  final String arabicName;
  final String englishName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String? teacherInviteCode;
}
