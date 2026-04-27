import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc(this._repository) : super(AdminState.initial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<LoadPendingUsers>(_onLoadPendingUsers);
    on<LoadRejectedUsers>(_onLoadRejectedUsers);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<LoadUsersByRole>(_onLoadUsersByRole);
    on<ApproveUser>(_onApproveUser);
    on<RejectUser>(_onRejectUser);
    on<SuspendUser>(_onSuspendUser);
    on<ReactivateUser>(_onReactivateUser);
    on<AssignTeacher>(_onAssignTeacher);
    on<RemoveTeacher>(_onRemoveTeacher);
    on<LoadSystemStats>(_onLoadSystemStats);
    on<LoadReportData>(_onLoadReportData);
    on<LoadSystemSettings>(_onLoadSystemSettings);
    on<UpdateSystemSettings>(_onUpdateSystemSettings);
    on<RefreshAdmin>(_onRefreshAdmin);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    // Load multiple data sources for dashboard
    final (stats, statsFailure) = await _repository.getSystemStats();
    final (pending, pendingFailure) = await _repository.getPendingUsers();

    if (statsFailure != null || pendingFailure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: statsFailure?.message ?? pendingFailure?.message ?? 'Failed to load dashboard',
      ));
      return;
    }

    emit(state.copyWith(
      status: AdminStatus.loaded,
      systemStats: stats,
      pendingUsers: pending,
      lastUpdated: DateTime.now(),
    ));
  }

  Future<void> _onLoadPendingUsers(
    LoadPendingUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (users, failure) = await _repository.getPendingUsers();

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        pendingUsers: users,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadRejectedUsers(
    LoadRejectedUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (users, failure) = await _repository.getRejectedUsers();

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        rejectedUsers: users,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (users, failure) = await _repository.getAllUsers();

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        allUsers: users,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadUsersByRole(
    LoadUsersByRole event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (users, failure) = await _repository.getUsersByRole(event.role);

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        usersByRole: users,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onApproveUser(
    ApproveUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.approving));

    final failure = await _repository.approveUser(event.userId);

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh pending users
      add(const LoadPendingUsers());
    }
  }

  Future<void> _onRejectUser(
    RejectUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.rejecting));

    final failure = await _repository.rejectUser(
      event.userId,
      reason: event.reason,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh pending users
      add(const LoadPendingUsers());
    }
  }

  Future<void> _onSuspendUser(
    SuspendUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.suspending));

    final failure = await _repository.suspendUser(
      event.userId,
      reason: event.reason,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh all users
      add(const LoadAllUsers());
    }
  }

  Future<void> _onReactivateUser(
    ReactivateUser event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.reactivating));

    final failure = await _repository.reactivateUser(event.userId);

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh all users
      add(const LoadAllUsers());
    }
  }

  Future<void> _onAssignTeacher(
    AssignTeacher event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.assigning));

    final failure = await _repository.assignTeacher(
      studentId: event.studentId,
      teacherId: event.teacherId,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh all users
      add(const LoadAllUsers());
    }
  }

  Future<void> _onRemoveTeacher(
    RemoveTeacher event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.assigning));

    final failure = await _repository.removeTeacher(event.studentId);

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh all users
      add(const LoadAllUsers());
    }
  }

  Future<void> _onLoadSystemStats(
    LoadSystemStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (stats, failure) = await _repository.getSystemStats();

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        systemStats: stats,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadReportData(
    LoadReportData event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (report, failure) = await _repository.getReportData(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        reportData: report,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadSystemSettings(
    LoadSystemSettings event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    final (settings, failure) = await _repository.getSystemSettings();

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        systemSettings: settings,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onUpdateSystemSettings(
    UpdateSystemSettings event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.updating));

    final failure = await _repository.updateSystemSettings(event.settings);

    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: AdminStatus.loaded,
        systemSettings: event.settings,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onRefreshAdmin(
    RefreshAdmin event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));

    // Refresh dashboard data
    add(const LoadDashboard());
  }
}
