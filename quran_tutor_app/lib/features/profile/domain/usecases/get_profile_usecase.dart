import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting current user profile
class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  /// Execute get profile
  Future<(UserProfile?, Failure?)> call() async {
    return await repository.getCurrentProfile();
  }
}

/// Use case for getting profile by ID
class GetProfileByIdUseCase {
  final ProfileRepository repository;

  const GetProfileByIdUseCase(this.repository);

  /// Execute get profile by ID
  Future<(UserProfile?, Failure?)> call(String userId) async {
    return await repository.getProfileById(userId);
  }
}
