import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';

/// Repository interface for session operations
abstract class SessionsRepository {
  /// Get session by ID
  Future<(Session?, Failure?)> getSession(String sessionId);

  /// Get sessions for a teacher
  Future<(List<Session>?, Failure?)> getTeacherSessions(String teacherId);

  /// Get sessions for a student
  Future<(List<Session>?, Failure?)> getStudentSessions(String studentId);

  /// Get all sessions (admin only)
  Future<(List<Session>?, Failure?)> getAllSessions();

  /// Get upcoming sessions
  Future<(List<Session>?, Failure?)> getUpcomingSessions({String? userId});

  /// Get past sessions
  Future<(List<Session>?, Failure?)> getPastSessions({String? userId});

  /// Create new session
  Future<(Session?, Failure?)> createSession({
    required String teacherId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? topic,
    String? notes,
    String? location,
    bool isOnline = true,
  });

  /// Assign student to session
  Future<Failure?> assignStudent({
    required String sessionId,
    required String studentId,
  });

  /// Remove student from session
  Future<Failure?> unassignStudent(String sessionId);

  /// Update session
  Future<(Session?, Failure?)> updateSession(Session session);

  /// Cancel session
  Future<Failure?> cancelSession(String sessionId, {String? reason});

  /// Reschedule session
  Future<(Session?, Failure?)> rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  });

  /// Start session
  Future<(Session?, Failure?)> startSession(String sessionId);

  /// Complete session
  Future<(Session?, Failure?)> completeSession(String sessionId);

  /// Get sessions by date range
  Future<(List<Session>?, Failure?)> getSessionsInRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  });

  /// Get sessions for a specific day
  Future<(List<Session>?, Failure?)> getSessionsForDay(DateTime date,
      {String? userId});

  /// Get available time slots for a teacher
  Future<(List<DateTime>?, Failure?)> getAvailableSlots({
    required String teacherId,
    required DateTime date,
  });

  /// Stream of session updates
  Stream<List<Session>> get sessionsStream;
}
