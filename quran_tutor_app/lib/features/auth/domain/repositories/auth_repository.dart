import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

/// Abstract repository interface for authentication
/// 
/// This interface defines the contract for authentication operations
/// and is implemented by both Supabase and Firebase datasources.
abstract class AuthRepository {
  /// Get the currently authenticated user
  /// 
  /// Returns [AuthUser] if authenticated, empty user otherwise
  Future<AuthUser> getCurrentUser();

  /// Sign in with email and password
  /// 
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> signIn({
    required String email,
    required String password,
  });

  /// Sign up a new student
  /// 
  /// Creates user with student role and pending status
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> signUpStudent({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required DateTime dateOfBirth,
    required String phoneNumber,
    String? teacherInviteCode,
  });

  /// Sign up a new teacher
  /// 
  /// Creates user with teacher role and pending status
  /// Returns [AuthUser] on success, [Failure] on error
  Future<(AuthUser?, Failure?)> signUpTeacher({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required String phoneNumber,
    String? bio,
    String? websiteUrl,
  });

  /// Sign out the current user
  /// 
  /// Clears local tokens and session
  Future<void> signOut();

  /// Reset password for email
  /// 
  /// Sends password reset email
  Future<Failure?> resetPassword(String email);

  /// Update password
  /// 
  /// Updates the current user's password
  Future<Failure?> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Resend verification email
  /// 
  /// Only applicable for email verification flows
  Future<Failure?> resendVerificationEmail(String email);

  /// Listen to auth state changes
  /// 
  /// Stream emits updated AuthUser on auth state changes
  Stream<AuthUser> get authStateChanges;

  /// Refresh user data from backend
  /// 
  /// Useful for checking approval status updates
  Future<(AuthUser?, Failure?)> refreshUser();
}
