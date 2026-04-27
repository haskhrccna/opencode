import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/entities/auth_user.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_state.freezed.dart';

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

@freezed
class AdminState with _$AdminState {
  const factory AdminState({
    required AdminStatus status,
    List<AuthUser>? pendingUsers,
    List<AuthUser>? rejectedUsers,
    List<AuthUser>? allUsers,
    List<AuthUser>? usersByRole,
    SystemStats? systemStats,
    ReportData? reportData,
    SystemSettings? systemSettings,
    String? errorMessage,
    DateTime? lastUpdated,
  }) = _AdminState;

  factory AdminState.initial() => const AdminState(
        status: AdminStatus.initial,
      );
}
