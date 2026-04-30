import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:quran_tutor_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quran_tutor_app/features/auth/data/models/user_model.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/domain/repositories/auth_repository.dart';

@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<AuthUser> getCurrentUser() async {
    final cachedUser = await localDataSource.getUserData();
    if (cachedUser != null) {
      try {
        return UserModel.fromJson(cachedUser).toEntity();
      } catch (_) {}
    }
    final remoteUser = await remoteDataSource.getCurrentUser();
    if (remoteUser != null) {
      await localDataSource.cacheUserData(remoteUser.toJson());
      return remoteUser.toEntity();
    }
    return AuthUser.empty();
  }

  @override
  Future<(AuthUser?, Failure?)> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signIn(email, password);
      await localDataSource.cacheUserData(userModel.toJson());
      return (userModel.toEntity(), null);
    } on AuthException catch (e) {
      return (null, AuthFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return (null, ValidationFailure.invalidInput(message: e.message));
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
      await localDataSource.cacheUserData(userModel.toJson());
      return (userModel.toEntity(), null);
    } on AuthException catch (e) {
      return (null, AuthFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return (null, ValidationFailure.invalidInput(message: e.message));
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
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
    } on AuthException catch (e) {
      return AuthFailure(message: e.message, code: e.code);
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
  Stream<AuthUser> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((userModel) async {
      if (userModel != null) {
        await localDataSource.cacheUserData(userModel.toJson());
        return userModel.toEntity();
      }
      await localDataSource.clearAll();
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
        await localDataSource.cacheUserData(refreshedUser.toJson());
        return (refreshedUser.toEntity(), null);
      }
      return (AuthUser.empty(), null);
    } on ServerException catch (e) {
      return (null, _mapServerExceptionToFailure(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkExceptionToFailure(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
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
