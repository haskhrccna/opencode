import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpStudentRequested>(_onSignUpStudentRequested);
    on<SignUpTeacherRequested>(_onSignUpTeacherRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<RefreshUserRequested>(_onRefreshUserRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
  }
  final AuthRepository _authRepository;

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.getCurrentUser();
      if (user.isAuthenticated) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),);
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (user, failure) = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );
    if (user != null && failure == null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),);
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure?.message ?? 'Login failed',
      ),);
    }
  }

  Future<void> _onSignUpStudentRequested(
    SignUpStudentRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (user, failure) = await _authRepository.signUpStudent(
      email: event.email,
      password: event.password,
      arabicName: event.arabicName,
      englishName: event.englishName,
      dateOfBirth: event.dateOfBirth,
      phoneNumber: event.phoneNumber,
      teacherInviteCode: event.teacherInviteCode,
    );
    if (user != null && failure == null) {
      if (user.isPending) {
        emit(state.copyWith(
          status: AuthStatus.pendingApproval,
          user: user,
        ),);
      } else {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),);
      }
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure?.message ?? 'Sign up failed',
      ),);
    }
  }

  Future<void> _onSignUpTeacherRequested(
    SignUpTeacherRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (user, failure) = await _authRepository.signUpTeacher(
      email: event.email,
      password: event.password,
      arabicName: event.arabicName,
      englishName: event.englishName,
      phoneNumber: event.phoneNumber,
      bio: event.bio,
      websiteUrl: event.websiteUrl,
    );
    if (user != null && failure == null) {
      if (user.isPending) {
        emit(state.copyWith(
          status: AuthStatus.pendingApproval,
          user: user,
        ),);
      } else {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),);
      }
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure?.message ?? 'Sign up failed',
      ),);
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onRefreshUserRequested(
    RefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final (user, failure) = await _authRepository.refreshUser();
    if (user != null && failure == null) {
      if (user.isPending) {
        emit(state.copyWith(
          status: AuthStatus.pendingApproval,
          user: user,
        ),);
      } else if (user.isRejected) {
        emit(state.copyWith(
          status: AuthStatus.rejected,
          user: user,
        ),);
      } else if (user.isAuthenticated) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),);
      }
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final failure = await _authRepository.resetPassword(event.email);
    if (failure != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),);
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final failure = await _authRepository.updatePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    if (failure != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),);
    }
  }
}
