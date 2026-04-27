import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.started() = AuthStarted;

  const factory AuthEvent.signInRequested({
    required String email,
    required String password,
  }) = SignInRequested;

  const factory AuthEvent.signUpStudentRequested({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required DateTime dateOfBirth,
    required String phoneNumber,
    String? teacherInviteCode,
  }) = SignUpStudentRequested;

  const factory AuthEvent.signUpTeacherRequested({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required String phoneNumber,
    String? bio,
    String? websiteUrl,
  }) = SignUpTeacherRequested;

  const factory AuthEvent.signOutRequested() = SignOutRequested;

  const factory AuthEvent.refreshUserRequested() = RefreshUserRequested;

  const factory AuthEvent.resetPasswordRequested({
    required String email,
  }) = ResetPasswordRequested;

  const factory AuthEvent.updatePasswordRequested({
    required String currentPassword,
    required String newPassword,
  }) = UpdatePasswordRequested;
}
