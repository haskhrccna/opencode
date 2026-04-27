import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'profile_event.freezed.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.loadProfile() = LoadProfile;

  const factory ProfileEvent.loadProfileById(String userId) = LoadProfileById;

  const factory ProfileEvent.updateProfile({
    String? arabicName,
    String? englishName,
    String? phoneNumber,
    String? bio,
    String? websiteUrl,
    DateTime? dateOfBirth,
  }) = UpdateProfile;

  const factory ProfileEvent.uploadAvatar(File imageFile) = UploadAvatar;

  const factory ProfileEvent.deleteAvatar() = DeleteAvatar;

  const factory ProfileEvent.updatePassword({
    required String currentPassword,
    required String newPassword,
  }) = UpdatePassword;

  const factory ProfileEvent.loadTeachers() = LoadTeachers;

  const factory ProfileEvent.loadStudentsByTeacher(String teacherId) = LoadStudentsByTeacher;

  const factory ProfileEvent.linkStudentToTeacher({
    required String studentId,
    required String teacherId,
  }) = LinkStudentToTeacher;

  const factory ProfileEvent.unlinkStudentFromTeacher(String studentId) = UnlinkStudentFromTeacher;

  const factory ProfileEvent.refreshProfile() = RefreshProfile;
}
