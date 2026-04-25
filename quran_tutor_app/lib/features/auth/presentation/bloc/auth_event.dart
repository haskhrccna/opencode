import 'package:equatable/equatable.dart';

/// Auth events for the AuthBloc
///
/// These events represent all possible user interactions
/// with the authentication system.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the app starts
///
/// Used to check if user is already authenticated
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Event triggered when user requests sign in
class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const SignInRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

/// Event triggered when student requests sign up
class SignUpStudentRequested extends AuthEvent {
  final String email;
  final String password;
  final String arabicName;
  final String englishName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String? teacherInviteCode;

  const SignUpStudentRequested({
    required this.email,
    required this.password,
    required this.arabicName,
    required this.englishName,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.teacherInviteCode,
  });

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

/// Event triggered when teacher requests sign up
class SignUpTeacherRequested extends AuthEvent {
  final String email;
  final String password;
  final String arabicName;
  final String englishName;
  final String phoneNumber;
  final String? bio;
  final String? websiteUrl;

  const SignUpTeacherRequested({
    required this.email,
    required this.password,
    required this.arabicName,
    required this.englishName,
    required this.phoneNumber,
    this.bio,
    this.websiteUrl,
  });

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

/// Event triggered when user requests sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event triggered when user requests password reset
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Event triggered when user updates their password
class UpdatePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Event triggered when auth state changes (from auth stream)
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged({
    required this.isAuthenticated,
  });

  @override
  List<Object?> get props => [isAuthenticated];
}

/// Event triggered to refresh user data
///
/// Used for checking approval status updates
class RefreshUserRequested extends AuthEvent {
  const RefreshUserRequested();
}

/// Event triggered when user requests resend verification email
class ResendVerificationEmailRequested extends AuthEvent {
  final String email;

  const ResendVerificationEmailRequested(this.email);

  @override
  List<Object?> get props => [email];
}
