import 'package:equatable/equatable.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

enum AdminStatus {
  initial,
  loading,
  loaded,
  approving,
  rejecting,
  suspending,
  reactivating,
  assigning,
  updating,
  error,
}

class AdminState extends Equatable {

  const AdminState({
    required this.status,
    this.pendingUsers,
    this.rejectedUsers,
    this.allUsers,
    this.usersByRole,
    this.systemStats,
    this.reportData,
    this.systemSettings,
    this.errorMessage,
    this.lastUpdated,
  });

  factory AdminState.initial() => const AdminState(
        status: AdminStatus.initial,
      );
  final AdminStatus status;
  final List<AuthUser>? pendingUsers;
  final List<AuthUser>? rejectedUsers;
  final List<AuthUser>? allUsers;
  final List<AuthUser>? usersByRole;
  final SystemStats? systemStats;
  final ReportData? reportData;
  final SystemSettings? systemSettings;
  final String? errorMessage;
  final DateTime? lastUpdated;

  AdminState copyWith({
    AdminStatus? status,
    List<AuthUser>? pendingUsers,
    List<AuthUser>? rejectedUsers,
    List<AuthUser>? allUsers,
    List<AuthUser>? usersByRole,
    SystemStats? systemStats,
    ReportData? reportData,
    SystemSettings? systemSettings,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return AdminState(
      status: status ?? this.status,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      rejectedUsers: rejectedUsers ?? this.rejectedUsers,
      allUsers: allUsers ?? this.allUsers,
      usersByRole: usersByRole ?? this.usersByRole,
      systemStats: systemStats ?? this.systemStats,
      reportData: reportData ?? this.reportData,
      systemSettings: systemSettings ?? this.systemSettings,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pendingUsers,
        rejectedUsers,
        allUsers,
        usersByRole,
        systemStats,
        reportData,
        systemSettings,
        errorMessage,
        lastUpdated,
      ];
}
