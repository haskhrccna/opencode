import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends AdminEvent {
  const LoadDashboard();
}

class LoadPendingUsers extends AdminEvent {
  const LoadPendingUsers();
}

class LoadRejectedUsers extends AdminEvent {
  const LoadRejectedUsers();
}

class LoadAllUsers extends AdminEvent {
  const LoadAllUsers();
}

class LoadUsersByRole extends AdminEvent {
  const LoadUsersByRole(this.role);
  final UserRole role;

  @override
  List<Object?> get props => [role];
}

class ApproveUser extends AdminEvent {
  const ApproveUser(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

class RejectUser extends AdminEvent {
  const RejectUser({required this.userId, this.reason});
  final String userId;
  final String? reason;

  @override
  List<Object?> get props => [userId, reason];
}

class SuspendUser extends AdminEvent {
  const SuspendUser({required this.userId, this.reason});
  final String userId;
  final String? reason;

  @override
  List<Object?> get props => [userId, reason];
}

class ReactivateUser extends AdminEvent {
  const ReactivateUser(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

class AssignTeacher extends AdminEvent {
  const AssignTeacher({required this.studentId, required this.teacherId});
  final String studentId;
  final String teacherId;

  @override
  List<Object?> get props => [studentId, teacherId];
}

class RemoveTeacher extends AdminEvent {
  const RemoveTeacher(this.studentId);
  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

class LoadSystemStats extends AdminEvent {
  const LoadSystemStats();
}

class LoadReportData extends AdminEvent {
  const LoadReportData({required this.startDate, required this.endDate});
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadSystemSettings extends AdminEvent {
  const LoadSystemSettings();
}

class UpdateSystemSettings extends AdminEvent {
  const UpdateSystemSettings(this.settings);
  final SystemSettings settings;

  @override
  List<Object?> get props => [settings];
}

class RefreshAdmin extends AdminEvent {
  const RefreshAdmin();
}
