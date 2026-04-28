import 'package:equatable/equatable.dart';

import '../../domain/repositories/admin_repository.dart';

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
  final UserRole role;

  const LoadUsersByRole(this.role);

  @override
  List<Object?> get props => [role];
}

class ApproveUser extends AdminEvent {
  final String userId;

  const ApproveUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RejectUser extends AdminEvent {
  final String userId;
  final String? reason;

  const RejectUser({required this.userId, this.reason});

  @override
  List<Object?> get props => [userId, reason];
}

class SuspendUser extends AdminEvent {
  final String userId;
  final String? reason;

  const SuspendUser({required this.userId, this.reason});

  @override
  List<Object?> get props => [userId, reason];
}

class ReactivateUser extends AdminEvent {
  final String userId;

  const ReactivateUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AssignTeacher extends AdminEvent {
  final String studentId;
  final String teacherId;

  const AssignTeacher({required this.studentId, required this.teacherId});

  @override
  List<Object?> get props => [studentId, teacherId];
}

class RemoveTeacher extends AdminEvent {
  final String studentId;

  const RemoveTeacher(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadSystemStats extends AdminEvent {
  const LoadSystemStats();
}

class LoadReportData extends AdminEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadReportData({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadSystemSettings extends AdminEvent {
  const LoadSystemSettings();
}

class UpdateSystemSettings extends AdminEvent {
  final SystemSettings settings;

  const UpdateSystemSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class RefreshAdmin extends AdminEvent {
  const RefreshAdmin();
}
