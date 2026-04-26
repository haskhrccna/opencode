import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';

/// Auth states for the AuthBloc
///
/// These states represent all possible authentication states
/// the app can be in.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before checking authentication
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is signed in and approved
class Authenticated extends AuthState {
  final AuthUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'Authenticated(user: ${user.email})';
}

/// Unauthenticated state - user is not signed in
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Pending approval state - user signed up but waiting for admin approval
class PendingApproval extends AuthState {
  final String userId;
  final String email;

  const PendingApproval({
    required this.userId,
    required this.email,
  });

  @override
  List<Object?> get props => [userId, email];
}

/// Rejected state - user registration was rejected by admin
class Rejected extends AuthState {
  final String userId;
  final String email;
  final String? reason;

  const Rejected({
    required this.userId,
    required this.email,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, email, reason];
}

/// Suspended state - user account was suspended
class Suspended extends AuthState {
  final String userId;
  final String email;
  final String? reason;

  const Suspended({
    required this.userId,
    required this.email,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, email, reason];
}

/// Authentication failure state - error occurred during auth operation
class AuthFailureState extends AuthState {
  final Failure failure;

  const AuthFailureState(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'AuthFailureState(failure: ${failure.message})';
}

/// Password reset sent state
class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Sign up success state - user created but pending approval
class SignUpSuccess extends AuthState {
  final String email;
  final String userId;

  const SignUpSuccess({
    required this.email,
    required this.userId,
  });

  @override
  List<Object?> get props => [email, userId];
}

/// Extension methods for AuthState
extension AuthStateX on AuthState {
  /// Check if user is authenticated
  bool get isAuthenticated => this is Authenticated;

  /// Check if user is pending approval
  bool get isPending => this is PendingApproval;

  /// Check if user is rejected
  bool get isRejected => this is Rejected;

  /// Check if user is suspended
  bool get isSuspended => this is Suspended;

  /// Check if there's an error
  bool get hasError => this is AuthFailureState;

  /// Check if currently loading
  bool get isLoading => this is AuthLoading;

  /// Get current user if authenticated
  AuthUser? get user {
    if (this is Authenticated) {
      return (this as Authenticated).user;
    }
    return null;
  }

  /// Get error message if failed
  String? get errorMessage {
    if (this is AuthFailureState) {
      return (this as AuthFailureState).failure.message;
    }
    return null;
  }

  /// Get user-friendly error message
  String? get userErrorMessage {
    if (this is AuthFailureState) {
      return (this as AuthFailureState).failure.userMessage;
    }
    return null;
  }
}
