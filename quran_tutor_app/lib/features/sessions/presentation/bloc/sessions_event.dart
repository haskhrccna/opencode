import 'package:freezed_annotation/freezed_annotation.dart';

part 'sessions_event.freezed.dart';

@freezed
class SessionsEvent with _$SessionsEvent {
  const factory SessionsEvent.loadSessions({String? userId}) = LoadSessions;

  const factory SessionsEvent.loadTeacherSessions(String teacherId) = LoadTeacherSessions;

  const factory SessionsEvent.loadStudentSessions(String studentId) = LoadStudentSessions;

  const factory SessionsEvent.loadAllSessions() = LoadAllSessions;

  const factory SessionsEvent.loadUpcomingSessions({String? userId}) = LoadUpcomingSessions;

  const factory SessionsEvent.loadPastSessions({String? userId}) = LoadPastSessions;

  const factory SessionsEvent.getSession(String sessionId) = GetSession;

  const factory SessionsEvent.createSession({
    required String teacherId,
    required DateTime scheduledAt,
    int durationMinutes,
    String? topic,
    String? notes,
    String? location,
    bool isOnline,
  }) = CreateSession;

  const factory SessionsEvent.assignStudent({
    required String sessionId,
    required String studentId,
  }) = AssignStudent;

  const factory SessionsEvent.unassignStudent(String sessionId) = UnassignStudent;

  const factory SessionsEvent.updateSession({
    required String sessionId,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? topic,
    String? notes,
    String? location,
    bool? isOnline,
  }) = UpdateSession;

  const factory SessionsEvent.cancelSession({
    required String sessionId,
    String? reason,
  }) = CancelSession;

  const factory SessionsEvent.rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  }) = RescheduleSession;

  const factory SessionsEvent.startSession(String sessionId) = StartSession;

  const factory SessionsEvent.completeSession(String sessionId) = CompleteSession;

  const factory SessionsEvent.loadSessionsInRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) = LoadSessionsInRange;

  const factory SessionsEvent.refreshSessions() = RefreshSessions;
}
