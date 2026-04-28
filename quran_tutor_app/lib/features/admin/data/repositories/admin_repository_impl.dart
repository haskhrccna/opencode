import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

/// Stub implementation of AdminRepository
class AdminRepositoryImpl implements AdminRepository {
  @override
  Future<(List<AuthUser>?, Failure?)> getPendingUsers() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<AuthUser>?, Failure?)> getRejectedUsers() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<AuthUser>?, Failure?)> getAllUsers() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<AuthUser>?, Failure?)> getUsersByRole(UserRole role) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<Failure?> approveUser(String userId) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> rejectUser(String userId, {String? reason}) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> suspendUser(String userId, {String? reason}) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> reactivateUser(String userId) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> assignTeacher({
    required String studentId,
    required String teacherId,
  }) async => const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> removeTeacher(String studentId) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<(SystemStats?, Failure?)> getSystemStats() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(ReportData?, Failure?)> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) async => (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(String?, Failure?)> exportReportToPdf(ReportData report) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(SystemSettings?, Failure?)> getSystemSettings() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<Failure?> updateSystemSettings(SystemSettings settings) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Stream<List<AuthUser>> get pendingUsersStream =>
      const Stream<List<AuthUser>>.empty();
}
