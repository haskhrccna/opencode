import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class SignInRequested extends AuthEvent {

  const SignInRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignUpStudentRequested extends AuthEvent {

  const SignUpStudentRequested({
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

  @override
  List<Object?> get props => [
        email,
        password,
        arabicName,
        englishName,
        dateOfBirth,
        phoneNumber,
        teacherInviteCode,
      ];
}

class SignUpTeacherRequested extends AuthEvent {

  const SignUpTeacherRequested({
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

  @override
  List<Object?> get props => [
        email,
        password,
        arabicName,
        englishName,
        phoneNumber,
        bio,
        websiteUrl,
      ];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class RefreshUserRequested extends AuthEvent {
  const RefreshUserRequested();
}

class ResetPasswordRequested extends AuthEvent {

  const ResetPasswordRequested({required this.email});
  final String email;

  @override
  List<Object?> get props => [email];
}

class UpdatePasswordRequested extends AuthEvent {

  const UpdatePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
