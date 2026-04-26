import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/logging/app_logger.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_student_usecase.dart';
import '../../domain/usecases/sign_up_teacher_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for authentication
///
/// Manages authentication state and handles all auth-related events
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpStudentUseCase _signUpStudentUseCase;
  final SignUpTeacherUseCase _signUpTeacherUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RefreshUserUseCase _refreshUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final AuthRepository _authRepository;
  final _logger = AppLogger();

  StreamSubscription<AuthUser>? _authStateSubscription;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpStudentUseCase signUpStudentUseCase,
    required SignUpTeacherUseCase signUpTeacherUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RefreshUserUseCase refreshUserUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpStudentUseCase = signUpStudentUseCase,
        _signUpTeacherUseCase = signUpTeacherUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _refreshUserUseCase = refreshUserUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpStudentRequested>(_onSignUpStudentRequested);
    on<SignUpTeacherRequested>(_onSignUpTeacherRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<RefreshUserRequested>(_onRefreshUserRequested);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);

    // Subscribe to auth state changes
    _subscribeToAuthStateChanges();
  }

  /// Subscribe to auth state changes from repository
  void _subscribeToAuthStateChanges() {
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (isClosed) return;
        
        add(AuthStateChanged(isAuthenticated: user.isAuthenticated));
      },
      onError: (error) {
        _logger.e('Auth state stream error', error: error);
      },
    );
  }

  /// Handle AppStarted event
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _getCurrentUserUseCase();

      if (user.isAuthenticated) {
        _emitAuthenticated(emit, user);
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      _logger.e('Error during app start', error: e);
      emit(const Unauthenticated());
    }
  }

  /// Handle SignInRequested event
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final (user, failure) = await _signInUseCase(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    if (failure != null) {
      _logger.e('Sign in failed', error: failure.message);
      emit(AuthFailureState(failure));
      return;
    }

    if (user != null) {
      _emitAuthenticated(emit, user);
    }
  }

  /// Handle SignUpStudentRequested event
  Future<void> _onSignUpStudentRequested(
    SignUpStudentRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final (user, failure) = await _signUpStudentUseCase(
      SignUpStudentParams(
        email: event.email,
        password: event.password,
        arabicName: event.arabicName,
        englishName: event.englishName,
        dateOfBirth: event.dateOfBirth,
        phoneNumber: event.phoneNumber,
        teacherInviteCode: event.teacherInviteCode,
      ),
    );

    if (failure != null) {
      _logger.e('Student sign up failed', error: failure.message);
      emit(AuthFailureState(failure));
      return;
    }

    if (user != null) {
      // New students are always pending approval
      emit(PendingApproval(
        userId: user.id,
        email: user.email,
      ));
    }
  }

  /// Handle SignUpTeacherRequested event
  Future<void> _onSignUpTeacherRequested(
    SignUpTeacherRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final (user, failure) = await _signUpTeacherUseCase(
      SignUpTeacherParams(
        email: event.email,
        password: event.password,
        arabicName: event.arabicName,
        englishName: event.englishName,
        phoneNumber: event.phoneNumber,
        bio: event.bio,
        websiteUrl: event.websiteUrl,
      ),
    );

    if (failure != null) {
      _logger.e('Teacher sign up failed', error: failure.message);
      emit(AuthFailureState(failure));
      return;
    }

    if (user != null) {
      // New teachers are always pending approval
      emit(PendingApproval(
        userId: user.id,
        email: user.email,
      ));
    }
  }

  /// Handle SignOutRequested event
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _signOutUseCase();
      emit(const Unauthenticated());
    } catch (e) {
      _logger.e('Sign out error', error: e);
      emit(AuthFailureState(UnknownFailure(message: e.toString())));
    }
  }

  /// Handle ResetPasswordRequested event
  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final failure = await _resetPasswordUseCase(event.email);

    if (failure != null) {
      _logger.e('Password reset failed', error: failure.message);
      emit(AuthFailureState(failure));
      return;
    }

    emit(PasswordResetSent(event.email));
  }

  /// Handle UpdatePasswordRequested event
  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final failure = await _authRepository.updatePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    if (failure != null) {
      _logger.e('Password update failed', error: failure.message);
      emit(AuthFailureState(failure));
      return;
    }

    // Emit current authenticated state
    if (state is Authenticated) {
      emit(state);
    }
  }

  /// Handle AuthStateChanged event
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    // Skip if currently in loading state to avoid conflicts
    if (state is AuthLoading) return;

    if (event.isAuthenticated) {
      // Refresh user data to get latest status
      final (user, failure) = await _refreshUserUseCase();

      if (failure != null) {
        _logger.w('Failed to refresh user', error: failure.message);
        emit(const Unauthenticated());
        return;
      }

      if (user != null && user.isAuthenticated) {
        _emitAuthenticated(emit, user);
      } else {
        emit(const Unauthenticated());
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  /// Handle RefreshUserRequested event
  Future<void> _onRefreshUserRequested(
    RefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Don't show loading for background refresh
    final (user, failure) = await _refreshUserUseCase();

    if (failure != null) {
      _logger.w('Failed to refresh user', error: failure.message);
      return;
    }

    if (user != null) {
      _emitAuthenticated(emit, user);
    }
  }

  /// Handle ResendVerificationEmailRequested event
  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final failure = await _authRepository.resendVerificationEmail(event.email);

    if (failure != null) {
      _logger.e('Resend verification email failed', error: failure.message);
      emit(AuthFailureState(failure));
      return;
    }

    // Emit previous state
    if (state is PendingApproval) {
      emit(state);
    }
  }

  /// Helper to emit appropriate authenticated state based on user status
  void _emitAuthenticated(Emitter<AuthState> emit, AuthUser user) {
    switch (user.status) {
      case UserStatus.approved:
        emit(Authenticated(user));
        break;
      case UserStatus.pending:
        emit(PendingApproval(
          userId: user.id,
          email: user.email,
        ));
        break;
      case UserStatus.rejected:
        emit(Rejected(
          userId: user.id,
          email: user.email,
        ));
        break;
      case UserStatus.suspended:
        emit(Suspended(
          userId: user.id,
          email: user.email,
        ));
        break;
    }
  }

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logging/app_logger.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_student_usecase.dart';
import '../../domain/usecases/sign_up_teacher_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for authentication
///
/// Manages authentication state and handles all auth-related events
class AuthBloc extends Bloc<AuthEvent, AuthState> {
