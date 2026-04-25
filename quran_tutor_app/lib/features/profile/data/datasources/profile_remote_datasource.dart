import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

/// Abstract remote datasource for profile operations
abstract class ProfileRemoteDataSource {
  /// Get profile by user ID
  Future<ProfileModel?> getProfile(String userId);

  /// Get current user profile
  Future<ProfileModel?> getCurrentProfile();

  /// Update profile
  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// Upload avatar image
  Future<String> uploadAvatar(String userId, File imageFile);

  /// Delete avatar
  Future<void> deleteAvatar(String userId);

  /// Get teachers
  Future<List<ProfileModel>> getTeachers();

  /// Get students by teacher ID
  Future<List<ProfileModel>> getStudentsByTeacher(String teacherId);

  /// Link student to teacher
  Future<void> linkStudentToTeacher(String studentId, String teacherId);

  /// Unlink student from teacher
  Future<void> unlinkStudentFromTeacher(String studentId);
}

/// Supabase implementation
class SupabaseProfileDataSource implements ProfileRemoteDataSource {
  final SupabaseClient _supabase;

  SupabaseProfileDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response == null) return null;
      return ProfileModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<ProfileModel?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return getProfile(user.id);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      await _supabase
          .from('users')
          .update(profile.toSupabase())
          .eq('id', profile.id);

      return profile;
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileName = 'avatars/$userId.jpg';
      
      await _supabase.storage
          .from('profiles')
          .upload(fileName, imageFile);

      final url = _supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    try {
      final fileName = 'avatars/$userId.jpg';
      await _supabase.storage.from('profiles').remove([fileName]);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<ProfileModel>> getTeachers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'teacher')
          .eq('status', 'approved');

      return (response as List)
          .map((e) => ProfileModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<ProfileModel>> getStudentsByTeacher(String teacherId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'student')
          .eq('teacher_id', teacherId);

      return (response as List)
          .map((e) => ProfileModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> linkStudentToTeacher(String studentId, String teacherId) async {
    try {
      await _supabase
          .from('users')
          .update({'teacher_id': teacherId})
          .eq('id', studentId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> unlinkStudentFromTeacher(String studentId) async {
    try {
      await _supabase
          .from('users')
          .update({'teacher_id': null})
          .eq('id', studentId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }
}

/// Firebase implementation (fallback)
class FirebaseProfileDataSource implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseProfileDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return ProfileModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<ProfileModel?> getCurrentProfile() async {
    // Get from Firebase Auth current user
    // Implementation depends on Firebase Auth
    throw UnimplementedError();
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .update(profile.toFirestore());
      return profile;
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('avatars/$userId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    try {
      final ref = _storage.ref().child('avatars/$userId.jpg');
      await ref.delete();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<ProfileModel>> getTeachers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .where('status', isEqualTo: 'approved')
          .get();

      return snapshot.docs
          .map((doc) => ProfileModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<ProfileModel>> getStudentsByTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs
          .map((doc) => ProfileModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> linkStudentToTeacher(String studentId, String teacherId) async {
    try {
      await _firestore
          .collection('users')
          .doc(studentId)
          .update({'teacherId': teacherId});
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> unlinkStudentFromTeacher(String studentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(studentId)
          .update({'teacherId': FieldValue.delete()});
    } catch (e) {
      throw ServerException.internalError();
    }
  }
}
