import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Stub AuthBloc for Phase 0 - Make It Compile
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignOutRequested>(_onSignOutRequested);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    // TODO: Check authentication status
    emit(const Unauthenticated());
  }

  void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) {
    // TODO: Sign out user
    emit(const Unauthenticated());
  }
}
