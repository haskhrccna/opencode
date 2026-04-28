import 'dart:io';

import 'package:equatable/equatable.dart';


abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class LoadProfileById extends ProfileEvent {

  const LoadProfileById(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {

  const UpdateProfile({
    this.arabicName,
    this.englishName,
    this.phoneNumber,
    this.bio,
    this.websiteUrl,
    this.dateOfBirth,
  });
  final String? arabicName;
  final String? englishName;
  final String? phoneNumber;
  final String? bio;
  final String? websiteUrl;
  final DateTime? dateOfBirth;

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

  const UploadAvatar(this.imageFile);
  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}

class DeleteAvatar extends ProfileEvent {
  const DeleteAvatar();
}

class UpdatePassword extends ProfileEvent {

  const UpdatePassword({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class LoadTeachers extends ProfileEvent {
  const LoadTeachers();
}

class LoadStudentsByTeacher extends ProfileEvent {

  const LoadStudentsByTeacher(this.teacherId);
  final String teacherId;

  @override
  List<Object?> get props => [teacherId];
}

class LinkStudentToTeacher extends ProfileEvent {

  const LinkStudentToTeacher({
    required this.studentId,
    required this.teacherId,
  });
  final String studentId;
  final String teacherId;

  @override
  List<Object?> get props => [studentId, teacherId];
}

class UnlinkStudentFromTeacher extends ProfileEvent {

  const UnlinkStudentFromTeacher(this.studentId);
  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}
