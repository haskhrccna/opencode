import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  SignInRequested({required this.email, required this.password});
}

class SignOutRequested extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>((event, emit) => emit(Unauthenticated()));
    on<SignInRequested>((event, emit) => emit(Unauthenticated()));
    on<SignOutRequested>((event, emit) => emit(Unauthenticated()));
  }
}
