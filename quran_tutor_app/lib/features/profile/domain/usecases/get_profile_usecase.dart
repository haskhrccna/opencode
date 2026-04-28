import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting current user profile
class GetProfileUseCase {

  const GetProfileUseCase(this.repository);
  final ProfileRepository repository;

  /// Execute get profile
  Future<(UserProfile?, Failure?)> call() async {
    return repository.getCurrentProfile();
  }
}

/// Use case for getting profile by ID
class GetProfileByIdUseCase {

  const GetProfileByIdUseCase(this.repository);
  final ProfileRepository repository;

  /// Execute get profile by ID
  Future<(UserProfile?, Failure?)> call(String userId) async {
    return repository.getProfileById(userId);
  }
}
