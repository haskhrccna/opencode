import 'dart:io';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  /// Execute update profile
  Future<(UserProfile?, Failure?)> call(UserProfile profile) async {
    return await repository.updateProfile(profile);
  }
}

/// Use case for uploading avatar
class UploadAvatarUseCase {
  final ProfileRepository repository;

  const UploadAvatarUseCase(this.repository);

  /// Execute upload avatar
  Future<(UserProfile?, Failure?)> call(File imageFile) async {
    return await repository.uploadAvatar(imageFile);
  }
}

/// Use case for deleting avatar
class DeleteAvatarUseCase {
  final ProfileRepository repository;

  const DeleteAvatarUseCase(this.repository);

  /// Execute delete avatar
  Future<Failure?> call() async {
    return await repository.deleteAvatar();
  }
}
