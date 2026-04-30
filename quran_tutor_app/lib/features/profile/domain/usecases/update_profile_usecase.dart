import 'dart:io';

import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this.repository);
  final ProfileRepository repository;

  /// Execute update profile
  Future<(UserProfile?, Failure?)> call(UserProfile profile) async {
    return repository.updateProfile(profile);
  }
}

/// Use case for uploading avatar
class UploadAvatarUseCase {
  const UploadAvatarUseCase(this.repository);
  final ProfileRepository repository;

  /// Execute upload avatar
  Future<(UserProfile?, Failure?)> call(File imageFile) async {
    return repository.uploadAvatar(imageFile);
  }
}

/// Use case for deleting avatar
class DeleteAvatarUseCase {
  const DeleteAvatarUseCase(this.repository);
  final ProfileRepository repository;

  /// Execute delete avatar
  Future<Failure?> call() async {
    return repository.deleteAvatar();
  }
}
