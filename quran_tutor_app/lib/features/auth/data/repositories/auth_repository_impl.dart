import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
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
  Future<AuthUser> getCurrentUser() async {
    // First try to get from local cache for instant load
    final cachedUser = await localDataSource.getUserData();
    if (cachedUser != null) {
      try {
        return UserModel.fromSupabase(cachedUser).toEntity();
      } catch (e) {
        // If parsing fails, continue to remote
      }
    }

    // Try to get from remote
    final remoteUser = await remoteDataSource.getCurrentUser();
    if (remoteUser != null) {
      // Cache user data
      await localDataSource.cacheUserData(remoteUser.toSupabaseJson());
      return remoteUser.toEntity();
    }

    // Return empty user if not authenticated
    return AuthUser.empty();
  }

  @override
  Future<(AuthUser?, Failure?)> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signIn(email, password);
      
      // Cache user data and token
      await localDataSource.cacheUserData(userModel.toSupabaseJson());
      
      return (userModel.toEntity(), null);
    } on AuthException catch (e) {
      return (null, _mapAuthExceptionToFailure(e));
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(AuthUser?, Failure?)> signUpStudent({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required DateTime dateOfBirth,
    required String phoneNumber,
    String? teacherInviteCode,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpStudent(
        email: email,
        password: password,
        arabicName: arabicName,
        englishName: englishName,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        teacherInviteCode: teacherInviteCode,
      );

      // Cache user data
      await localDataSource.cacheUserData(userModel.toSupabaseJson());

      return (userModel.toEntity(), null);
    } on AuthException catch (e) {
      return (null, _mapAuthExceptionToFailure(e));
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on ValidationException catch (e) {
      return (null, ValidationFailure.invalidInput(message: e.message));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(AuthUser?, Failure?)> signUpTeacher({
    required String email,
    required String password,
    required String arabicName,
    required String englishName,
    required String phoneNumber,
    String? bio,
    String? websiteUrl,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpTeacher(
        email: email,
        password: password,
        arabicName: arabicName,
        englishName: englishName,
        phoneNumber: phoneNumber,
        bio: bio,
        websiteUrl: websiteUrl,
      );

      // Cache user data
      await localDataSource.cacheUserData(userModel.toSupabaseJson());

      return (userModel.toEntity(), null);
    } on AuthException catch (e) {
      return (null, _mapAuthExceptionToFailure(e));
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
    } on AuthException catch (e) {
      return _mapAuthExceptionToFailure(e);
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
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.updatePassword(currentPassword, newPassword);
      return null;
    } on AuthException catch (e) {
      return _mapAuthExceptionToFailure(e);
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
    } on AuthException catch (e) {
      return _mapAuthExceptionToFailure(e);
    } on ServerException catch (e) {
      return _mapServerExceptionToFailure(e);
    } on NetworkException catch (e) {
      return _mapNetworkExceptionToFailure(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Stream<AuthUser> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        // Cache user data on auth state change
        localDataSource.cacheUserData(userModel.toSupabaseJson());
        return userModel.toEntity();
      }
      // Clear cache on sign out
      localDataSource.clearAll();
      return AuthUser.empty();
    });
  }

  @override
  Future<(AuthUser?, Failure?)> refreshUser() async {
    final currentUser = await remoteDataSource.getCurrentUser();
    if (currentUser == null) {
      return (AuthUser.empty(), null);
    }

    try {
      final refreshedUser = await remoteDataSource.refreshUser(currentUser.id);
      if (refreshedUser != null) {
        // Update cache
        await localDataSource.cacheUserData(refreshedUser.toSupabaseJson());
        return (refreshedUser.toEntity(), null);
      }
      return (AuthUser.empty(), null);
    } on AuthException catch (e) {
      return (null, _mapAuthExceptionToFailure(e));
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  // Exception mapping helpers
  Failure _mapAuthExceptionToFailure(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
      case 'wrong_password':
        return AuthFailure.invalidCredentials();
      case 'user_not_found':
        return AuthFailure.userNotFound();
      case 'email_already_in_use':
        return AuthFailure.emailAlreadyInUse();
      case 'weak_password':
        return AuthFailure.weakPassword();
      case 'invalid_email':
        return AuthFailure.invalidEmail();
      case 'user_disabled':
        return AuthFailure.userDisabled();
      case 'too_many_requests':
        return AuthFailure.tooManyRequests();
      case 'operation_not_allowed':
        return AuthFailure.operationNotAllowed();
      case 'session_expired':
        return AuthFailure.sessionExpired();
      case 'unauthenticated':
        return AuthFailure.unauthenticated();
      default:
        return AuthFailure(message: e.message, code: e.code);
    }
  }

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
