import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/entities/auth_user.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_event.freezed.dart';

@freezed
class AdminEvent with _$AdminEvent {
  const factory AdminEvent.loadDashboard() = LoadDashboard;

  const factory AdminEvent.loadPendingUsers() = LoadPendingUsers;

  const factory AdminEvent.loadRejectedUsers() = LoadRejectedUsers;

  const factory AdminEvent.loadAllUsers() = LoadAllUsers;

  const factory AdminEvent.loadUsersByRole(UserRole role) = LoadUsersByRole;

  const factory AdminEvent.approveUser(String userId) = ApproveUser;

  const factory AdminEvent.rejectUser({
    required String userId,
    String? reason,
  }) = RejectUser;

  const factory AdminEvent.suspendUser({
    required String userId,
    String? reason,
  }) = SuspendUser;

  const factory AdminEvent.reactivateUser(String userId) = ReactivateUser;

  const factory AdminEvent.assignTeacher({
    required String studentId,
    required String teacherId,
  }) = AssignTeacher;

  const factory AdminEvent.removeTeacher(String studentId) = RemoveTeacher;

  const factory AdminEvent.loadSystemStats() = LoadSystemStats;

  const factory AdminEvent.loadReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) = LoadReportData;

  const factory AdminEvent.loadSystemSettings() = LoadSystemSettings;

  const factory AdminEvent.updateSystemSettings(SystemSettings settings) = UpdateSystemSettings;

  const factory AdminEvent.refreshAdmin() = RefreshAdmin;
}
