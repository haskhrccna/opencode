import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  pendingApproval,
  rejected,
  error,
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required AuthStatus status,
    AuthUser? user,
    String? errorMessage,
  }) = _AuthState;

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
}
