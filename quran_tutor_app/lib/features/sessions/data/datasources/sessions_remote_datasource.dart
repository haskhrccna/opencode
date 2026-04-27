import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/session_model.dart';

/// Abstract remote datasource for sessions
abstract class SessionsRemoteDataSource {
  /// Get session by ID
  Future<SessionModel?> getSession(String sessionId);

  /// Get sessions for teacher
  Future<List<SessionModel>> getTeacherSessions(String teacherId);

  /// Get sessions for student
  Future<List<SessionModel>> getStudentSessions(String studentId);

  /// Get all sessions (admin)
  Future<List<SessionModel>> getAllSessions();

  /// Create new session
  Future<SessionModel> createSession({
    required String teacherId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? topic,
    String? notes,
    String? location,
    bool isOnline = true,
  });

  /// Assign student to session
  Future<void> assignStudent(String sessionId, String studentId);

  /// Update session
  Future<SessionModel> updateSession(SessionModel session);

  /// Cancel session
  Future<void> cancelSession(String sessionId, {String? reason});

  /// Reschedule session
  Future<SessionModel> rescheduleSession(String sessionId, DateTime newScheduledAt);

  /// Complete session
  Future<SessionModel> completeSession(String sessionId);

  /// Get sessions in date range
  Future<List<SessionModel>> getSessionsInRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  });
}

/// Supabase implementation with UTC handling
class SupabaseSessionsDataSource implements SessionsRemoteDataSource {
  final SupabaseClient _supabase;

  SupabaseSessionsDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<SessionModel?> getSession(String sessionId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .eq('id', sessionId)
          .single();

      if (response == null) return null;
      return SessionModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<SessionModel>> getTeacherSessions(String teacherId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .eq('teacher_id', teacherId)
          .order('scheduled_at', ascending: true);

      return (response as List)
          .map((e) => SessionModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<SessionModel>> getStudentSessions(String studentId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .eq('student_id', studentId)
          .order('scheduled_at', ascending: true);

      return (response as List)
          .map((e) => SessionModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<SessionModel>> getAllSessions() async {
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .order('scheduled_at', ascending: true);

      return (response as List)
          .map((e) => SessionModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<SessionModel> createSession({
    required String teacherId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? topic,
    String? notes,
    String? location,
    bool isOnline = true,
  }) async {
    try {
      // CRITICAL: Convert to UTC before storing
      final utcScheduledAt = scheduledAt.toUtc();

      final data = {
        'teacher_id': teacherId,
        'scheduled_at': utcScheduledAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        'topic': topic,
        'notes': notes,
        'location': location,
        'is_online': isOnline,
        'status': 'scheduled',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _supabase
          .from('sessions')
          .insert(data)
          .select()
          .single();

      return SessionModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> assignStudent(String sessionId, String studentId) async {
    try {
      await _supabase
          .from('sessions')
          .update({'student_id': studentId})
          .eq('id', sessionId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<SessionModel> updateSession(SessionModel session) async {
    try {
      // Ensure UTC timestamps
      final data = session.toSupabase();
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();

      final response = await _supabase
          .from('sessions')
          .update(data)
          .eq('id', session.id)
          .select()
          .single();

      return SessionModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> cancelSession(String sessionId, {String? reason}) async {
    try {
      await _supabase
          .from('sessions')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<SessionModel> rescheduleSession(
    String sessionId,
    DateTime newScheduledAt,
  ) async {
    try {
      // CRITICAL: Convert to UTC before storing
      final utcNewTime = newScheduledAt.toUtc();

      final response = await _supabase
          .from('sessions')
          .update({
            'scheduled_at': utcNewTime.toIso8601String(),
            'status': 'rescheduled',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionId)
          .select()
          .single();

      return SessionModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<SessionModel> completeSession(String sessionId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionId)
          .select()
          .single();

      return SessionModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<SessionModel>> getSessionsInRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) async {
    try {
      // CRITICAL: Convert to UTC for query
      final utcStart = start.toUtc();
      final utcEnd = end.toUtc();

      var query = _supabase
          .from('sessions')
          .select()
          .gte('scheduled_at', utcStart.toIso8601String())
          .lte('scheduled_at', utcEnd.toIso8601String());

      if (userId != null) {
        query = query.or('teacher_id.eq.$userId,student_id.eq.$userId');
      }

      final response = await query.order('scheduled_at', ascending: true);

      return (response as List)
          .map((e) => SessionModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }
}
