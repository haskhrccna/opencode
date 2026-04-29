import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:quran_tutor_app/features/profile/data/models/profile_model.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of ProfileRepository using remote datasource
@Singleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {

  ProfileRepositoryImpl({required this.remoteDataSource});
  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<(UserProfile?, Failure?)> getCurrentProfile() async {
    try {
      final model = await remoteDataSource.getCurrentProfile();
      if (model == null) {
        return (null, AuthFailure.unauthenticated());
      }
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(UserProfile?, Failure?)> getProfileById(String userId) async {
    try {
      final model = await remoteDataSource.getProfile(userId);
      if (model == null) {
        return (null, ServerFailure.notFound());
      }
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(UserProfile?, Failure?)> updateProfile(UserProfile profile) async {
    try {
      final model = ProfileModel.fromEntity(profile);
      final updated = await remoteDataSource.updateProfile(model);
      return (updated.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(UserProfile?, Failure?)> uploadAvatar(File imageFile) async {
    try {
      // Get current profile to obtain user ID
      final currentModel = await remoteDataSource.getCurrentProfile();
      if (currentModel == null) {
        return (null, AuthFailure.unauthenticated());
      }

      final userId = currentModel.id;
      final photoUrl = await remoteDataSource.uploadAvatar(userId, imageFile);

      // Update profile with new photo URL
      final updatedModel = currentModel.copyWith(photoUrl: photoUrl);
      final savedModel = await remoteDataSource.updateProfile(updatedModel);

      return (savedModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> deleteAvatar() async {
    try {
      // Get current profile to obtain user ID
      final currentModel = await remoteDataSource.getCurrentProfile();
      if (currentModel == null) {
        return AuthFailure.unauthenticated();
      }

      final userId = currentModel.id;
      await remoteDataSource.deleteAvatar(userId);

      // Update profile to remove photo URL
      final updatedModel = currentModel.copyWith(photoUrl: null);
      await remoteDataSource.updateProfile(updatedModel);

      return null;
    } on ServerException catch (e) {
      return _mapServerException(e);
    } on NetworkException catch (e) {
      return _mapNetworkException(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Password update is handled by AuthRepository
    // This method should delegate to auth or return not implemented
    return const BusinessFailure(
      message: 'Password update is handled by AuthRepository',
      code: 'password_update_not_in_profile_repo',
    );
  }

  @override
  Future<(List<UserProfile>?, Failure?)> getTeachers() async {
    try {
      final models = await remoteDataSource.getTeachers();
      final profiles = models.map((m) => m.toEntity()).toList();
      return (profiles, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<UserProfile>?, Failure?)> getStudentsByTeacher(String teacherId) async {
    try {
      final models = await remoteDataSource.getStudentsByTeacher(teacherId);
      final profiles = models.map((m) => m.toEntity()).toList();
      return (profiles, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> linkStudentToTeacher({
    required String studentId,
    required String teacherId,
  }) async {
    try {
      await remoteDataSource.linkStudentToTeacher(studentId, teacherId);
      return null;
    } on ServerException catch (e) {
      return _mapServerException(e);
    } on NetworkException catch (e) {
      return _mapNetworkException(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> unlinkStudentFromTeacher(String studentId) async {
    try {
      await remoteDataSource.unlinkStudentFromTeacher(studentId);
      return null;
    } on ServerException catch (e) {
      return _mapServerException(e);
    } on NetworkException catch (e) {
      return _mapNetworkException(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Stream<UserProfile> get profileUpdates {
    // TODO: Integrate with RealtimeService for live profile updates
    return const Stream<UserProfile>.empty();
  }

  Failure _mapServerException(ServerException e) {
    return ServerFailure(
      message: e.message,
      code: e.code,
      statusCode: e.statusCode,
    );
  }

  Failure _mapNetworkException(NetworkException e) {
    return NetworkFailure(
      message: e.message,
      code: e.code,
    );
  }
}
