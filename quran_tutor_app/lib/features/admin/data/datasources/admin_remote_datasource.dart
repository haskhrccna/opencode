import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
@Singleton(as: AdminRemoteDataSource)
class SupabaseAdminDataSource implements AdminRemoteDataSource {

  SupabaseAdminDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  final SupabaseClient _supabase;

  @override
  Future<List<UserModel>> getPendingUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
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
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
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
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
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
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
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
      final response = await _supabase.rpc<Map<String, dynamic>>('get_system_stats');

      return SystemStats(
        totalUsers: (response['total_users'] as num?)?.toInt() ?? 0,
        totalStudents: (response['total_students'] as num?)?.toInt() ?? 0,
        totalTeachers: (response['total_teachers'] as num?)?.toInt() ?? 0,
        totalAdmins: (response['total_admins'] as num?)?.toInt() ?? 0,
        pendingApprovals: (response['pending_approvals'] as num?)?.toInt() ?? 0,
        totalSessions: (response['total_sessions'] as num?)?.toInt() ?? 0,
        completedSessions: (response['completed_sessions'] as num?)?.toInt() ?? 0,
        cancelledSessions: (response['cancelled_sessions'] as num?)?.toInt() ?? 0,
        averageSessionDuration: (response['average_session_duration'] as num?)?.toDouble() ?? 0.0,
        averageGrade: (response['average_grade'] as num?)?.toDouble() ?? 0.0,
        newUsersThisWeek: (response['new_users_this_week'] as num?)?.toInt() ?? 0,
        activeUsersToday: (response['active_users_today'] as num?)?.toInt() ?? 0,
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
      final response = await _supabase.rpc<Map<String, dynamic>>('get_report_data', params: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },);

      return ReportData(
        title: (response['title'] as String?) ?? 'Report',
        startDate: startDate,
        endDate: endDate,
        sections: (response['sections'] as List? ?? [])
            .map((e) => ReportSection(
                  title: (e as Map<String, dynamic>)['title'] as String? ?? '',
                  content: e['content'] as String? ?? '',
                ),)
            .toList(),
        charts: (response['charts'] as List? ?? [])
            .map((e) => ReportChart(
                  title: (e as Map<String, dynamic>)['title'] as String? ?? '',
                  type: ChartType.values.byName((e['type'] as String?) ?? 'bar'),
                  data: (e['data'] as Map<String, dynamic>?) ?? {},
                ),)
            .toList(),
        tables: (response['tables'] as List? ?? [])
            .map((e) => ReportTable(
                  title: (e as Map<String, dynamic>)['title'] as String? ?? '',
                  headers: List<String>.from((e['headers'] as List?) ?? []),
                  rows: ((e['rows'] as List?) ?? [])
                      .map((r) => List<String>.from(r as List))
                      .toList(),
                ),)
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
        allowSelfRegistration: (response['allow_self_registration'] as bool?) ?? true,
        requireApproval: (response['require_approval'] as bool?) ?? true,
        defaultSessionDuration: (response['default_session_duration'] as num?)?.toInt() ?? 60,
        systemNotice: response['system_notice'] as String?,
        customSettings: response['custom_settings'] as Map<String, dynamic>?,
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
