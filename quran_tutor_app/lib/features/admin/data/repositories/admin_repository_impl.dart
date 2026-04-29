import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

/// Implementation of AdminRepository using remote datasource
@Singleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {

  AdminRepositoryImpl({required this.remoteDataSource});
  final AdminRemoteDataSource remoteDataSource;

  @override
  Future<(List<AuthUser>?, Failure?)> getPendingUsers() async {
    try {
      final models = await remoteDataSource.getPendingUsers();
      final users = models.map((m) => m.toEntity()).toList();
      return (users, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<AuthUser>?, Failure?)> getRejectedUsers() async {
    try {
      final models = await remoteDataSource.getRejectedUsers();
      final users = models.map((m) => m.toEntity()).toList();
      return (users, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<AuthUser>?, Failure?)> getAllUsers() async {
    try {
      final models = await remoteDataSource.getAllUsers();
      final users = models.map((m) => m.toEntity()).toList();
      return (users, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<AuthUser>?, Failure?)> getUsersByRole(UserRole role) async {
    try {
      final models = await remoteDataSource.getUsersByRole(role);
      final users = models.map((m) => m.toEntity()).toList();
      return (users, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> approveUser(String userId) async {
    try {
      await remoteDataSource.approveUser(userId);
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
  Future<Failure?> rejectUser(String userId, {String? reason}) async {
    try {
      await remoteDataSource.rejectUser(userId, reason: reason);
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
  Future<Failure?> suspendUser(String userId, {String? reason}) async {
    try {
      await remoteDataSource.suspendUser(userId, reason: reason);
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
  Future<Failure?> reactivateUser(String userId) async {
    try {
      await remoteDataSource.reactivateUser(userId);
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
  Future<Failure?> assignTeacher({
    required String studentId,
    required String teacherId,
  }) async {
    try {
      await remoteDataSource.assignTeacher(studentId, teacherId);
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
  Future<Failure?> removeTeacher(String studentId) async {
    try {
      await remoteDataSource.removeTeacher(studentId);
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
  Future<(SystemStats?, Failure?)> getSystemStats() async {
    try {
      final stats = await remoteDataSource.getSystemStats();
      return (stats, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(ReportData?, Failure?)> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final report = await remoteDataSource.getReportData(
        startDate: startDate,
        endDate: endDate,
      );
      return (report, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(String?, Failure?)> exportReportToPdf(ReportData report) async {
    // PDF generation is handled by PdfService in core/services/pdf/
    // This repository method returns the report data for PDF conversion
    // The actual PDF creation happens in the presentation layer or use case
    return (null, const BusinessFailure(
      message: 'Use PdfService directly for PDF generation',
      code: 'pdf_generation_not_implemented_in_repo',
    ));
  }

  @override
  Future<(SystemSettings?, Failure?)> getSystemSettings() async {
    try {
      final settings = await remoteDataSource.getSystemSettings();
      return (settings, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> updateSystemSettings(SystemSettings settings) async {
    try {
      await remoteDataSource.updateSystemSettings(settings);
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
  Stream<List<AuthUser>> get pendingUsersStream {
    // TODO: Integrate with RealtimeService for live pending users updates
    return const Stream<List<AuthUser>>.empty();
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
