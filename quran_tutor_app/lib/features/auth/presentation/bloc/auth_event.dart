part of 'auth_bloc.dart';

/// Auth events for the AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the app starts
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Event triggered when user requests sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event triggered when user requests sign in
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when student requests sign up
class SignUpStudentRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpStudentRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Event triggered when teacher requests sign up
class SignUpTeacherRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String inviteCode;

  const SignUpTeacherRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.inviteCode,
  });

  @override
  List<Object?> get props => [email, password, name, inviteCode];
}
