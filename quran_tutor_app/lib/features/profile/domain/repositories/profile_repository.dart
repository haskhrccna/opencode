import 'dart:io';

import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  /// Get current user profile
  Future<(UserProfile?, Failure?)> getCurrentProfile();

  /// Get profile by user ID
  Future<(UserProfile?, Failure?)> getProfileById(String userId);

  /// Update profile
  Future<(UserProfile?, Failure?)> updateProfile(UserProfile profile);

  /// Upload avatar image
  ///
  /// Returns updated profile with new photoUrl
  Future<(UserProfile?, Failure?)> uploadAvatar(File imageFile);

  /// Delete avatar
  Future<Failure?> deleteAvatar();

  /// Update password
  Future<Failure?> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Get teacher profiles
  Future<(List<UserProfile>?, Failure?)> getTeachers();

  /// Get student profiles by teacher ID
  Future<(List<UserProfile>?, Failure?)> getStudentsByTeacher(String teacherId);

  /// Link student to teacher
  Future<Failure?> linkStudentToTeacher({
    required String studentId,
    required String teacherId,
  });

  /// Unlink student from teacher
  Future<Failure?> unlinkStudentFromTeacher(String studentId);

  /// Stream of profile updates
  Stream<UserProfile> get profileUpdates;
}
