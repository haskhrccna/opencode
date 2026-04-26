import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class StudentSignUpRequested extends AuthEvent {
  final StudentSignupRequest request;

  const StudentSignUpRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class TeacherSignUpRequested extends AuthEvent {
  final TeacherSignupRequest request;

  const TeacherSignUpRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthUserChanged extends AuthEvent {
  final User? supabaseUser;

  const AuthUserChanged(this.supabaseUser);

  @override
  List<Object?> get props => [supabaseUser];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase;

  AuthBloc(this._supabase) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignIn);
    on<StudentSignUpRequested>(_onStudentSignUp);
    on<TeacherSignUpRequested>(_onTeacherSignUp);
    on<SignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onAuthUserChanged);

    _supabase.auth.onAuthStateChange.listen((data) {
      add(AuthUserChanged(data.session?.user));
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final session = _supabase.auth.currentSession;
    if (session == null) {
      emit(const Unauthenticated());
      return;
    }
    await _loadAndEmitUser(session.user.id, emit);
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.supabaseUser == null) {
      emit(const Unauthenticated());
      return;
    }
    await _loadAndEmitUser(event.supabaseUser!.id, emit);
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.user == null) {
        emit(const AuthError('فشل تسجيل الدخول'));
        return;
      }
      await _loadAndEmitUser(response.user!.id, emit);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e, st) {
      addError(e, st);
      emit(const AuthError('تعذر الاتصال بالخادم، تحقق من اتصالك بالإنترنت'));
    }
  }

  Future<void> _onStudentSignUp(
    StudentSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final r = event.request;
      final response = await _supabase.auth.signUp(
        email: r.email,
        password: r.password,
      );
      if (response.user == null) {
        emit(const AuthError('فشل إنشاء الحساب'));
        return;
      }
      await _supabase.from(AppConstants.profilesTable).insert({
        'id': response.user!.id,
        'name': r.name,
        'email': r.email,
        'phone': r.phone,
        'age': r.age,
        'role': UserRole.student.value,
        'status': UserStatus.pending.value,
        'preferred_level': r.preferredLevel,
      });
      await _loadAndEmitUser(response.user!.id, emit);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e, st) {
      addError(e, st);
      emit(const AuthError('تعذر إنشاء الحساب، تحقق من اتصالك بالإنترنت'));
    }
  }

  Future<void> _onTeacherSignUp(
    TeacherSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final r = event.request;
      final invite = await _supabase
          .from(AppConstants.teacherInvitesTable)
          .select()
          .eq('code', r.inviteCode)
          .eq('used', false)
          .maybeSingle();

      if (invite == null) {
        emit(const AuthError('رمز الدعوة غير صالح'));
        return;
      }

      final response = await _supabase.auth.signUp(
        email: r.email,
        password: r.password,
      );
      if (response.user == null) {
        emit(const AuthError('فشل إنشاء الحساب'));
        return;
      }
      await _supabase.from(AppConstants.profilesTable).insert({
        'id': response.user!.id,
        'name': r.name,
        'email': r.email,
        'phone': r.phone,
        'bio': r.bio,
        'role': UserRole.teacher.value,
        'status': UserStatus.pending.value,
      });
      await _supabase
          .from(AppConstants.teacherInvitesTable)
          .update({'used': true, 'used_by': response.user!.id})
          .eq('code', r.inviteCode);

      await _loadAndEmitUser(response.user!.id, emit);
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e, st) {
      addError(e, st);
      emit(const AuthError('تعذر إنشاء الحساب، تحقق من اتصالك بالإنترنت'));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _supabase.auth.signOut();
    emit(const Unauthenticated());
  }

  Future<void> _loadAndEmitUser(String userId, Emitter<AuthState> emit) async {
    try {
      final data = await _supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();
      emit(Authenticated(UserModel.fromJson(data)));
    } on PostgrestException catch (e) {
      emit(AuthError('تعذر تحميل بيانات المستخدم: ${e.message}'));
    } catch (e, st) {
      addError(e, st);
      emit(const AuthError('تعذر تحميل بيانات المستخدم'));
    }
  }
}
