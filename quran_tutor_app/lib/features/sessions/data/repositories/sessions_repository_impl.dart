import '../../../../core/error/failures.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/sessions_repository.dart';

/// Stub implementation of SessionsRepository
class SessionsRepositoryImpl implements SessionsRepository {
  @override
  Future<(Session?, Failure?)> getSession(String sessionId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getTeacherSessions(String teacherId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getStudentSessions(String studentId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getAllSessions() async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getUpcomingSessions({String? userId}) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getPastSessions({String? userId}) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(Session?, Failure?)> createSession({
    required String teacherId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? topic,
    String? notes,
    String? location,
    bool isOnline = true,
  }) async => (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<Failure?> assignStudent({
    required String sessionId,
    required String studentId,
  }) async => const ServerFailure(message: 'Not implemented');

  @override
  Future<Failure?> unassignStudent(String sessionId) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<(Session?, Failure?)> updateSession(Session session) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<Failure?> cancelSession(String sessionId, {String? reason}) async =>
      const ServerFailure(message: 'Not implemented');

  @override
  Future<(Session?, Failure?)> rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  }) async => (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(Session?, Failure?)> startSession(String sessionId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(Session?, Failure?)> completeSession(String sessionId) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getSessionsInRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) async => (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<Session>?, Failure?)> getSessionsForDay(DateTime date, {String? userId}) async =>
      (null, const ServerFailure(message: 'Not implemented'));

  @override
  Future<(List<DateTime>?, Failure?)> getAvailableSlots({
    required String teacherId,
    required DateTime date,
  }) async => (null, const ServerFailure(message: 'Not implemented'));

  @override
  Stream<List<Session>> get sessionsStream => Stream<List<Session>>.empty();
}
