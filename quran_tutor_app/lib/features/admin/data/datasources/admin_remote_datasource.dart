import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/admin_repository.dart';

/// Abstract remote datasource for admin operations
abstract class AdminRemoteDataSource {
  /// Get pending users
  Future<List<UserModel>> getPendingUsers();

  /// Get rejected users
  Future<List<UserModel>> getRejectedUsers();

  /// Get all users
  Future<List<UserModel>> getAllUsers();

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role);

  /// Approve user
  Future<void> approveUser(String userId);

  /// Reject user
  Future<void> rejectUser(String userId, {String? reason});

  /// Suspend user
  Future<void> suspendUser(String userId, {String? reason});

  /// Reactivate user
  Future<void> reactivateUser(String userId);

  /// Assign teacher to student
  Future<void> assignTeacher(String studentId, String teacherId);

  /// Remove teacher from student
  Future<void> removeTeacher(String studentId);

  /// Get system statistics
  Future<SystemStats> getSystemStats();

  /// Get report data
  Future<ReportData> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get system settings
  Future<SystemSettings> getSystemSettings();

  /// Update system settings
  Future<void> updateSystemSettings(SystemSettings settings);
}

/// Supabase implementation
class SupabaseAdminDataSource implements AdminRemoteDataSource {
  final SupabaseClient _supabase;

  SupabaseAdminDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<UserModel>> getPendingUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => UserModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<UserModel>> getRejectedUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('status', 'rejected')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => UserModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => UserModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', role.value)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => UserModel.fromSupabase(e))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> approveUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'status': 'approved',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> rejectUser(String userId, {String? reason}) async {
    try {
      await _supabase
          .from('users')
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> suspendUser(String userId, {String? reason}) async {
    try {
      await _supabase
          .from('users')
          .update({
            'status': 'suspended',
            'suspension_reason': reason,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> reactivateUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'status': 'approved',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> assignTeacher(String studentId, String teacherId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'teacher_id': teacherId,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', studentId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> removeTeacher(String studentId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'teacher_id': null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', studentId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<SystemStats> getSystemStats() async {
    try {
      final response = await _supabase.rpc('get_system_stats');

      return SystemStats(
        totalUsers: response['total_users'] ?? 0,
        totalStudents: response['total_students'] ?? 0,
        totalTeachers: response['total_teachers'] ?? 0,
        totalAdmins: response['total_admins'] ?? 0,
        pendingApprovals: response['pending_approvals'] ?? 0,
        totalSessions: response['total_sessions'] ?? 0,
        completedSessions: response['completed_sessions'] ?? 0,
        cancelledSessions: response['cancelled_sessions'] ?? 0,
        averageSessionDuration: (response['average_session_duration'] ?? 0).toDouble(),
        averageGrade: (response['average_grade'] ?? 0).toDouble(),
        newUsersThisWeek: response['new_users_this_week'] ?? 0,
        activeUsersToday: response['active_users_today'] ?? 0,
      );
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<ReportData> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase.rpc('get_report_data', params: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      return ReportData(
        title: response['title'] ?? 'Report',
        startDate: startDate,
        endDate: endDate,
        sections: (response['sections'] as List? ?? [])
            .map((e) => ReportSection(
                  title: e['title'],
                  content: e['content'],
                ))
            .toList(),
        charts: (response['charts'] as List? ?? [])
            .map((e) => ReportChart(
                  title: e['title'],
                  type: ChartType.values.byName(e['type']),
                  data: e['data'],
                ))
            .toList(),
        tables: (response['tables'] as List? ?? [])
            .map((e) => ReportTable(
                  title: e['title'],
                  headers: List<String>.from(e['headers']),
                  rows: (e['rows'] as List)
                      .map((r) => List<String>.from(r))
                      .toList(),
                ))
            .toList(),
      );
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await _supabase
          .from('system_settings')
          .select()
          .single();

      return SystemSettings(
        allowSelfRegistration: response['allow_self_registration'] ?? true,
        requireApproval: response['require_approval'] ?? true,
        defaultSessionDuration: response['default_session_duration'] ?? 60,
        systemNotice: response['system_notice'],
        customSettings: response['custom_settings'],
      );
    } catch (e) {
      // Return default settings if not found
      return const SystemSettings();
    }
  }

  @override
  Future<void> updateSystemSettings(SystemSettings settings) async {
    try {
      await _supabase
          .from('system_settings')
          .upsert({
            'allow_self_registration': settings.allowSelfRegistration,
            'require_approval': settings.requireApproval,
            'default_session_duration': settings.defaultSessionDuration,
            'system_notice': settings.systemNotice,
            'custom_settings': settings.customSettings,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
    } catch (e) {
      throw ServerException.internalError();
    }
  }
}
