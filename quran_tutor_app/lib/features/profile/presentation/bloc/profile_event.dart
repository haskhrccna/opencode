import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class LoadProfileById extends ProfileEvent {
  final String userId;

  const LoadProfileById(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final String? arabicName;
  final String? englishName;
  final String? phoneNumber;
  final String? bio;
  final String? websiteUrl;
  final DateTime? dateOfBirth;

  const UpdateProfile({
    this.arabicName,
    this.englishName,
    this.phoneNumber,
    this.bio,
    this.websiteUrl,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props => [
        arabicName,
        englishName,
        phoneNumber,
        bio,
        websiteUrl,
        dateOfBirth,
      ];
}

class UploadAvatar extends ProfileEvent {
  final File imageFile;

  const UploadAvatar(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class DeleteAvatar extends ProfileEvent {
  const DeleteAvatar();
}

class UpdatePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const UpdatePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class LoadTeachers extends ProfileEvent {
  const LoadTeachers();
}

class LoadStudentsByTeacher extends ProfileEvent {
  final String teacherId;

  const LoadStudentsByTeacher(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class LinkStudentToTeacher extends ProfileEvent {
  final String studentId;
  final String teacherId;

  const LinkStudentToTeacher({
    required this.studentId,
    required this.teacherId,
  });

  @override
  List<Object?> get props => [studentId, teacherId];
}

class UnlinkStudentFromTeacher extends ProfileEvent {
  final String studentId;

  const UnlinkStudentFromTeacher(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}
