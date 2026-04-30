import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:quran_tutor_app/features/sessions/data/models/session_model.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';
import 'package:quran_tutor_app/features/sessions/domain/repositories/sessions_repository.dart';

/// Implementation of SessionsRepository using remote datasource
@Singleton(as: SessionsRepository)
class SessionsRepositoryImpl implements SessionsRepository {
  SessionsRepositoryImpl({required this.remoteDataSource});
  final SessionsRemoteDataSource remoteDataSource;

  @override
  Future<(Session?, Failure?)> getSession(String sessionId) async {
    try {
      final model = await remoteDataSource.getSession(sessionId);
      if (model == null) {
        return (null, ServerFailure.notFound());
      }
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getTeacherSessions(
      String teacherId) async {
    try {
      final models = await remoteDataSource.getTeacherSessions(teacherId);
      final sessions = models.map((m) => m.toEntity()).toList();
      return (sessions, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getStudentSessions(
      String studentId) async {
    try {
      final models = await remoteDataSource.getStudentSessions(studentId);
      final sessions = models.map((m) => m.toEntity()).toList();
      return (sessions, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getAllSessions() async {
    try {
      final models = await remoteDataSource.getAllSessions();
      final sessions = models.map((m) => m.toEntity()).toList();
      return (sessions, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getUpcomingSessions(
      {String? userId}) async {
    try {
      final now = DateTime.now().toUtc();
      final models = await remoteDataSource.getSessionsInRange(
        start: now,
        end: now.add(const Duration(days: 365)),
        userId: userId,
      );
      final sessions = models
          .map((m) => m.toEntity())
          .where((s) => s.status == SessionStatus.scheduled)
          .toList();
      return (sessions, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getPastSessions({String? userId}) async {
    try {
      final now = DateTime.now().toUtc();
      final models = await remoteDataSource.getSessionsInRange(
        start: now.subtract(const Duration(days: 365)),
        end: now,
        userId: userId,
      );
      final sessions = models
          .map((m) => m.toEntity())
          .where((s) =>
              s.status == SessionStatus.completed ||
              s.status == SessionStatus.cancelled)
          .toList();
      return (sessions, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(Session?, Failure?)> createSession({
    required String teacherId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? topic,
    String? notes,
    String? location,
    bool isOnline = true,
  }) async {
    try {
      final model = await remoteDataSource.createSession(
        teacherId: teacherId,
        scheduledAt: scheduledAt,
        durationMinutes: durationMinutes,
        topic: topic,
        notes: notes,
        location: location,
        isOnline: isOnline,
      );
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> assignStudent({
    required String sessionId,
    required String studentId,
  }) async {
    try {
      await remoteDataSource.assignStudent(sessionId, studentId);
      return null;
    } on ServerException catch (e) {
      return _mapServerException(e);
    } on NetworkException catch (e) {
      return _mapNetworkException(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> unassignStudent(String sessionId) async {
    try {
      await remoteDataSource.unassignStudent(sessionId);
      return null;
    } on ServerException catch (e) {
      return _mapServerException(e);
    } on NetworkException catch (e) {
      return _mapNetworkException(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<(Session?, Failure?)> updateSession(Session session) async {
    try {
      final model = SessionModel.fromEntity(session);
      final updated = await remoteDataSource.updateSession(model);
      return (updated.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> cancelSession(String sessionId, {String? reason}) async {
    try {
      await remoteDataSource.cancelSession(sessionId, reason: reason);
      return null;
    } on ServerException catch (e) {
      return _mapServerException(e);
    } on NetworkException catch (e) {
      return _mapNetworkException(e);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<(Session?, Failure?)> rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  }) async {
    try {
      final model = await remoteDataSource.rescheduleSession(
        sessionId,
        newScheduledAt,
      );
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(Session?, Failure?)> startSession(String sessionId) async {
    try {
      final model = await remoteDataSource.startSession(sessionId);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(Session?, Failure?)> completeSession(String sessionId) async {
    try {
      final model = await remoteDataSource.completeSession(sessionId);
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getSessionsInRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) async {
    try {
      final models = await remoteDataSource.getSessionsInRange(
        start: start,
        end: end,
        userId: userId,
      );
      final sessions = models.map((m) => m.toEntity()).toList();
      return (sessions, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<Session>?, Failure?)> getSessionsForDay(
    DateTime date, {
    String? userId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getSessionsInRange(start: start, end: end, userId: userId);
  }

  @override
  Future<(List<DateTime>?, Failure?)> getAvailableSlots({
    required String teacherId,
    required DateTime date,
  }) async {
    try {
      // Get all sessions for the teacher on this date
      final dayStart = DateTime(date.year, date.month, date.day).toUtc();
      final dayEnd = dayStart.add(const Duration(days: 1));
      final models = await remoteDataSource.getSessionsInRange(
        start: dayStart,
        end: dayEnd,
        userId: teacherId,
      );

      // Generate default slots (e.g., every hour from 8 AM to 8 PM)
      final slots = <DateTime>[];
      for (var hour = 8; hour < 20; hour++) {
        slots.add(DateTime(date.year, date.month, date.day, hour));
      }

      // Remove slots that overlap with existing sessions
      final existingSessions = models.map((m) => m.toEntity()).toList();
      final availableSlots = slots.where((slot) {
        return !existingSessions.any((session) {
          final sessionStart = session.scheduledAt.toLocal();
          final sessionEnd = session.endAt.toLocal();
          final slotUtc = slot.toUtc();
          return slotUtc
                  .isAfter(sessionStart.subtract(const Duration(minutes: 1))) &&
              slotUtc.isBefore(sessionEnd);
        });
      }).toList();

      return (availableSlots, null);
    } on ServerException catch (e) {
      return (null, _mapServerException(e));
    } on NetworkException catch (e) {
      return (null, _mapNetworkException(e));
    } catch (e) {
      return (null, UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Session>> get sessionsStream {
    // TODO: Integrate with RealtimeService for live session updates
    return const Stream<List<Session>>.empty();
  }

  Failure _mapServerException(ServerException e) {
    return ServerFailure(
      message: e.message,
      code: e.code,
      statusCode: e.statusCode,
    );
  }

  Failure _mapNetworkException(NetworkException e) {
    return NetworkFailure(
      message: e.message,
      code: e.code,
    );
  }
}
