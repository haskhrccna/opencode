import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Abstract remote datasource interface
abstract class AuthRemoteDataSource {
  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Sign in with email and password
  Future<UserModel> signIn(String email, String password);

  /// Sign up a new student
  Future<UserModel> signUpStudent({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required DateTime dateOfBirth,
    required String phoneNumber,
    String? teacherInviteCode,
  });

  /// Sign up a new teacher
  Future<UserModel> signUpTeacher({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required String phoneNumber,
    String? bio,
    String? websiteUrl,
  });

  /// Sign out
  Future<void> signOut();

  /// Reset password
  Future<void> resetPassword(String email);

  /// Update password
  Future<void> updatePassword(String currentPassword, String newPassword);

  /// Resend verification email
  Future<void> resendVerificationEmail(String email);

  /// Refresh user data
  Future<UserModel?> refreshUser(String userId);

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;
}

/// Supabase implementation of AuthRemoteDataSource
class SupabaseAuthDataSource implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  SupabaseAuthDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Fetch additional user data from users table
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabaseUser(user, response);
    } catch (e) {
      return UserModel.fromSupabaseUser(user, null);
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      debugPrint('🔐 RemoteDS: signInWithPassword for $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 RemoteDS: auth response user=${response.user?.id}');

      if (response.user == null) {
        throw const ServerException(message: 'Invalid credentials');
      }

      // Fetch user profile
      debugPrint('🔐 RemoteDS: querying users table for ${response.user!.id}');
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();
      debugPrint('🔐 RemoteDS: users table returned $userData');

      return UserModel.fromSupabaseUser(response.user!, userData);
    } on PostgrestException catch (e) {
      debugPrint('🔐 RemoteDS: PostgrestException: ${e.message}');
      throw ServerException(message: e.message);
    } catch (e) {
      debugPrint('🔐 RemoteDS: Exception: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpStudent({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required DateTime dateOfBirth,
    required String phoneNumber,
    String? teacherInviteCode,
  }) async {
    try {
      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': englishName,
          'arabic_name': arabicName,
        },
      );

      if (response.user == null) {
        throw const ServerException(message: 'Failed to create user');
      }

      // Validate teacher invite code if provided
      String? teacherId;
      if (teacherInviteCode != null && teacherInviteCode.isNotEmpty) {
        teacherId = await _validateTeacherInviteCode(teacherInviteCode);
      }

      // Create user profile
      final userData = {
        'id': response.user!.id,
        'email': email,
        'display_name': englishName,
        'arabic_name': arabicName,
        'role': 'student',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'teacher_id': teacherId,
      };

      await _supabase.from('users').insert(userData);

      // Notify admin of new registration
      await _notifyAdminOfRegistration(response.user!.id, 'student');

      return UserModel.fromJson(userData);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpTeacher({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required String phoneNumber,
    String? bio,
    String? websiteUrl,
  }) async {
    try {
      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': englishName,
          'arabic_name': arabicName,
        },
      );

      if (response.user == null) {
        throw const ServerException(message: 'Failed to create user');
      }

      // Create user profile
      final userData = {
        'id': response.user!.id,
        'email': email,
        'display_name': englishName,
        'arabic_name': arabicName,
        'role': 'teacher',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'phone_number': phoneNumber,
        'bio': bio,
        'website_url': websiteUrl,
      };

      await _supabase.from('users').insert(userData);

      // Notify admin of new registration
      await _notifyAdminOfRegistration(response.user!.id, 'teacher');

      return UserModel.fromJson(userData);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<String?> _validateTeacherInviteCode(String code) async {
    try {
      final response = await _supabase
          .from('teachers')
          .select('id')
          .eq('invite_code', code)
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> _notifyAdminOfRegistration(String userId, String role) async {
    try {
      await _supabase.from('admin_notifications').insert({
        'user_id': userId,
        'type': 'new_registration',
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      // Non-critical: log but don't throw
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  @override
  Future<UserModel?> refreshUser(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      return UserModel.fromSupabaseUser(authUser, response);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;

      return await getCurrentUser();
    });
  }
}
