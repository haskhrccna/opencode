import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/environment/app_environment.dart';
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
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromSupabase({
      'id': user.id,
      'email': user.email,
      ...response,
    });
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException.invalidCredentials();
      }

      // Fetch user profile
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromSupabase({
        'id': response.user!.id,
        'email': response.user!.email,
        ...userData,
      });
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException.unknown();
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
      );

      if (response.user == null) {
        throw ServerException.internalError();
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

      return UserModel.fromSupabase(userData);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException.internalError();
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
      );

      if (response.user == null) {
        throw ServerException.internalError();
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

      return UserModel.fromSupabase(userData);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  Future<String?> _validateTeacherInviteCode(String code) async {
    final response = await _supabase
        .from('teachers')
        .select('id')
        .eq('invite_code', code)
        .single();

    if (response == null) {
      throw ValidationException.invalidInput(message: 'Invalid invite code');
    }

    return response['id'] as String?;
  }

  Future<void> _notifyAdminOfRegistration(String userId, String role) async {
    // Insert into admin_notifications table
    await _supabase.from('admin_notifications').insert({
      'user_id': userId,
      'type': 'new_registration',
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
    });
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
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    if (response == null) return null;

    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    return UserModel.fromSupabase({
      'id': authUser.id,
      'email': authUser.email,
      ...response,
    });
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

/// Firebase implementation of AuthRemoteDataSource (fallback)
class FirebaseAuthDataSource implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirebase(user.uid, doc.data()!);
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw AuthException.invalidCredentials();
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        throw ServerException.notFound();
      }

      return UserModel.fromFirebase(user.uid, doc.data()!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed');
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
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw ServerException.internalError();
      }

      // Validate teacher invite code
      String? teacherId;
      if (teacherInviteCode != null && teacherInviteCode.isNotEmpty) {
        teacherId = await _validateTeacherInviteCode(teacherInviteCode);
      }

      final userData = {
        'email': email,
        'displayName': englishName,
        'arabicName': arabicName,
        'role': 'student',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': phoneNumber,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'teacherId': teacherId,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      // Notify admin
      await _notifyAdminOfRegistration(user.uid, 'student');

      return UserModel.fromFirebase(user.uid, {
        ...userData,
        'createdAt': DateTime.now(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign up failed');
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
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw ServerException.internalError();
      }

      final userData = {
        'email': email,
        'displayName': englishName,
        'arabicName': arabicName,
        'role': 'teacher',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': phoneNumber,
        'bio': bio,
        'websiteUrl': websiteUrl,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      // Notify admin
      await _notifyAdminOfRegistration(user.uid, 'teacher');

      return UserModel.fromFirebase(user.uid, {
        ...userData,
        'createdAt': DateTime.now(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign up failed');
    }
  }

  Future<String?> _validateTeacherInviteCode(String code) async {
    final snapshot = await _firestore
        .collection('teachers')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw ValidationException.invalidInput(message: 'Invalid invite code');
    }

    return snapshot.docs.first.id;
  }

  Future<void> _notifyAdminOfRegistration(String userId, String role) async {
    await _firestore.collection('admin_notifications').add({
      'userId': userId,
      'type': 'new_registration',
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException.unauthenticated();
    }

    // Re-authenticate user
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    // Firebase automatically sends verification email on sign up
    // This is a placeholder for manual resend if needed
  }

  @override
  Future<UserModel?> refreshUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    return UserModel.fromFirebase(userId, doc.data()!);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromFirebase(user.uid, doc.data()!);
    });
  }
}
