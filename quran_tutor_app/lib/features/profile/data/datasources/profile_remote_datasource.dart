import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/features/profile/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
@Singleton(as: ProfileRemoteDataSource)
class SupabaseProfileDataSource implements ProfileRemoteDataSource {

  SupabaseProfileDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  final SupabaseClient _supabase;

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

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
          .map((e) => ProfileModel.fromSupabase(e as Map<String, dynamic>))
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
          .map((e) => ProfileModel.fromSupabase(e as Map<String, dynamic>))
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
