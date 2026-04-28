import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

/// Repository interface for admin operations
abstract class AdminRepository {
  /// Get pending users for approval
  Future<(List<AuthUser>?, Failure?)> getPendingUsers();

  /// Get rejected users
  Future<(List<AuthUser>?, Failure?)> getRejectedUsers();

  /// Get all users
  Future<(List<AuthUser>?, Failure?)> getAllUsers();

  /// Get users by role
  Future<(List<AuthUser>?, Failure?)> getUsersByRole(UserRole role);

  /// Approve user
  Future<Failure?> approveUser(String userId);

  /// Reject user
  Future<Failure?> rejectUser(String userId, {String? reason});

  /// Suspend user
  Future<Failure?> suspendUser(String userId, {String? reason});

  /// Reactivate user
  Future<Failure?> reactivateUser(String userId);

  /// Assign teacher to student
  Future<Failure?> assignTeacher({
    required String studentId,
    required String teacherId,
  });

  /// Remove teacher from student
  Future<Failure?> removeTeacher(String studentId);

  /// Get system statistics
  Future<(SystemStats?, Failure?)> getSystemStats();

  /// Get report data
  Future<(ReportData?, Failure?)> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Export report to PDF
  Future<(String?, Failure?)> exportReportToPdf(ReportData report);

  /// Get system settings
  Future<(SystemSettings?, Failure?)> getSystemSettings();

  /// Update system settings
  Future<Failure?> updateSystemSettings(SystemSettings settings);

  /// Stream of pending users for real-time updates
  Stream<List<AuthUser>> get pendingUsersStream;
}

/// System statistics
class SystemStats extends Equatable {

  const SystemStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.pendingApprovals,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.averageSessionDuration,
    required this.averageGrade,
    required this.newUsersThisWeek,
    required this.activeUsersToday,
  });
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;
  final int pendingApprovals;
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final double averageSessionDuration;
  final double averageGrade;
  final int newUsersThisWeek;
  final int activeUsersToday;

  @override
  List<Object?> get props => [
        totalUsers,
        totalStudents,
        totalTeachers,
        totalAdmins,
        pendingApprovals,
        totalSessions,
        completedSessions,
        cancelledSessions,
        averageSessionDuration,
        averageGrade,
        newUsersThisWeek,
        activeUsersToday,
      ];
}

/// Report data for PDF export
class ReportData extends Equatable {

  const ReportData({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.sections,
    required this.charts,
    required this.tables,
  });
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<ReportSection> sections;
  final List<ReportChart> charts;
  final List<ReportTable> tables;

  @override
  List<Object?> get props => [title, startDate, endDate, sections, charts, tables];
}

/// Report section
class ReportSection extends Equatable {

  const ReportSection({
    required this.title,
    required this.content,
  });
  final String title;
  final String content;

  @override
  List<Object?> get props => [title, content];
}

/// Report chart
class ReportChart extends Equatable {

  const ReportChart({
    required this.title,
    required this.type,
    required this.data,
  });
  final String title;
  final ChartType type;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [title, type, data];
}

/// Chart types
enum ChartType { bar, line, pie, radar }

/// Report table
class ReportTable extends Equatable {

  const ReportTable({
    required this.title,
    required this.headers,
    required this.rows,
  });
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  List<Object?> get props => [title, headers, rows];
}

/// System settings
class SystemSettings extends Equatable {

  const SystemSettings({
    this.allowSelfRegistration = true,
    this.requireApproval = true,
    this.defaultSessionDuration = 60,
    this.systemNotice,
    this.customSettings,
  });
  final bool allowSelfRegistration;
  final bool requireApproval;
  final int defaultSessionDuration;
  final String? systemNotice;
  final Map<String, dynamic>? customSettings;

  @override
  List<Object?> get props => [
        allowSelfRegistration,
        requireApproval,
        defaultSessionDuration,
        systemNotice,
        customSettings,
      ];
}
