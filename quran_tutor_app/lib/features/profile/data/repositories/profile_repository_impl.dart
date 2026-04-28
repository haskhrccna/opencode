import 'dart:io';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Stub implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<(UserProfile?, Failure?)> getCurrentProfile() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(UserProfile?, Failure?)> getProfileById(String userId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(UserProfile?, Failure?)> updateProfile(UserProfile profile) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(UserProfile?, Failure?)> uploadAvatar(File imageFile) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<Failure?> deleteAvatar() async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const ServerFailure(message: 'Not implemented');

  @override
  Future<(List<UserProfile>?, Failure?)> getTeachers() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<UserProfile>?, Failure?)> getStudentsByTeacher(String teacherId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<Failure?> linkStudentToTeacher({
    required String studentId,
    required String teacherId,
  }) async => const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> unlinkStudentFromTeacher(String studentId) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Stream<UserProfile> get profileUpdates => Stream<UserProfile>.empty();
}
