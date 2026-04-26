import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
///
/// Handles data operations and maps exceptions to Failures
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> getCurrentUser() async {
    // First try to get from local cache for instant load
    final cachedUser = await localDataSource.getUserData();
    if (cachedUser != null) {
      try {
        return UserModel.fromJson(cachedUser).toEntity();
      } catch (e) {
        // If parsing fails, continue to remote
      }
    }

    // Try to get from remote
    final remoteUser = await remoteDataSource.getCurrentUser();
    if (remoteUser != null) {
      // Cache user data
      await localDataSource.cacheUserData(remoteUser.toJson());
      return remoteUser.toEntity();
    }

    // Return empty user if not authenticated
    return User.empty();
  }

  @override
  Future<(User?, Failure?)> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signIn(email, password);

      // Cache user data
      await localDataSource.cacheUserData(userModel.toJson());

      return (userModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(User?, Failure?)> signUpStudent({
    required String email,
    required String password,
    required String name,
    required String phone,
    int? age,
    String? teacherInviteCode,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpStudent(
        email: email,
        password: password,
        name: name,
        phone: phone,
        age: age,
        teacherInviteCode: teacherInviteCode,
      );

      // Cache user data
      await localDataSource.cacheUserData(userModel.toJson());

      return (userModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(User?, Failure?)> signUpTeacher({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? bio,
    String? websiteUrl,
    required String inviteCode,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpTeacher(
        email: email,
        password: password,
        name: name,
        phone: phone,
        bio: bio,
        websiteUrl: websiteUrl,
        inviteCode: inviteCode,
      );

      // Cache user data
      await localDataSource.cacheUserData(userModel.toJson());

      return (userModel.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearAll();
  }

  @override
  Future<Failure?> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return null;
    } on ServerException catch (e) {
      return _mapServerExceptionToFailure(e);
    } on NetworkException catch (e) {
      return _mapNetworkExceptionToFailure(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> updatePassword({
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return null;
    } on ServerException catch (e) {
      return _mapServerExceptionToFailure(e);
    } on NetworkException catch (e) {
      return _mapNetworkExceptionToFailure(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> resendVerificationEmail(String email) async {
    try {
      await remoteDataSource.resendVerificationEmail(email);
      return null;
    } on ServerException catch (e) {
      return _mapServerExceptionToFailure(e);
    } on NetworkException catch (e) {
      return _mapNetworkExceptionToFailure(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Stream<User> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        // Cache user data on auth state change
        localDataSource.cacheUserData(userModel.toJson());
        return userModel.toEntity();
      }
      // Clear cache on sign out
      localDataSource.clearAll();
      return User.empty();
    });
  }

  @override
  Future<(User?, Failure?)> refreshUser() async {
    final currentUser = await remoteDataSource.getCurrentUser();
    if (currentUser == null) {
      return (User.empty(), null);
    }

    try {
      final refreshedUser = await remoteDataSource.refreshUser(currentUser.id);
      if (refreshedUser != null) {
        // Update cache
        await localDataSource.cacheUserData(refreshedUser.toJson());
        return (refreshedUser.toEntity(), null);
      }
      return (User.empty(), null);
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  // Exception mapping helpers
  Failure _mapServerExceptionToFailure(ServerException e) {
    switch (e.code) {
      case 'bad_request':
        return ServerFailure.badRequest(message: e.message);
      case 'unauthorized':
        return ServerFailure.unauthorized();
      case 'forbidden':
        return ServerFailure.forbidden();
      case 'not_found':
        return ServerFailure.notFound();
      case 'conflict':
        return ServerFailure.conflict();
      case 'internal_error':
        return ServerFailure.internalError();
      default:
        return ServerFailure(
          message: e.message,
          code: e.code,
          statusCode: e.statusCode,
        );
    }
  }

  Failure _mapNetworkExceptionToFailure(NetworkException e) {
    switch (e.code) {
      case 'no_connection':
        return NetworkFailure.noConnection();
      case 'timeout':
        return NetworkFailure.timeout();
      default:
        return NetworkFailure(
          message: e.message,
          code: e.code,
        );
    }
  }
}
