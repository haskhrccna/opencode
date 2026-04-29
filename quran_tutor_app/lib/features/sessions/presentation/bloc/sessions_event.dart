import 'package:equatable/equatable.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessions extends SessionsEvent {
  const LoadSessions({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}

class LoadTeacherSessions extends SessionsEvent {
  const LoadTeacherSessions(this.teacherId);
  final String teacherId;

  @override
  List<Object?> get props => [teacherId];
}

class LoadStudentSessions extends SessionsEvent {
  const LoadStudentSessions(this.studentId);
  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

class LoadAllSessions extends SessionsEvent {
  const LoadAllSessions();
}

class LoadUpcomingSessions extends SessionsEvent {
  const LoadUpcomingSessions({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}

class LoadPastSessions extends SessionsEvent {
  const LoadPastSessions({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}

class GetSession extends SessionsEvent {
  const GetSession(this.sessionId);
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class CreateSession extends SessionsEvent {
  const CreateSession({
    required this.teacherId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.topic,
    this.notes,
    this.location,
    this.isOnline = true,
  });
  final String teacherId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? topic;
  final String? notes;
  final String? location;
  final bool isOnline;

  @override
  List<Object?> get props => [
        teacherId,
        scheduledAt,
        durationMinutes,
        topic,
        notes,
        location,
        isOnline,
      ];
}

class AssignStudent extends SessionsEvent {
  const AssignStudent({
    required this.sessionId,
    required this.studentId,
  });
  final String sessionId;
  final String studentId;

  @override
  List<Object?> get props => [sessionId, studentId];
}

class UnassignStudent extends SessionsEvent {
  const UnassignStudent(this.sessionId);
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class UpdateSession extends SessionsEvent {
  const UpdateSession({
    required this.sessionId,
    this.scheduledAt,
    this.durationMinutes,
    this.topic,
    this.notes,
    this.location,
    this.isOnline,
  });
  final String sessionId;
  final DateTime? scheduledAt;
  final int? durationMinutes;
  final String? topic;
  final String? notes;
  final String? location;
  final bool? isOnline;

  @override
  List<Object?> get props => [
        sessionId,
        scheduledAt,
        durationMinutes,
        topic,
        notes,
        location,
        isOnline,
      ];
}

class CancelSession extends SessionsEvent {
  const CancelSession({
    required this.sessionId,
    this.reason,
  });
  final String sessionId;
  final String? reason;

  @override
  List<Object?> get props => [sessionId, reason];
}

class RescheduleSession extends SessionsEvent {
  const RescheduleSession({
    required this.sessionId,
    required this.newScheduledAt,
  });
  final String sessionId;
  final DateTime newScheduledAt;

  @override
  List<Object?> get props => [sessionId, newScheduledAt];
}

class StartSession extends SessionsEvent {
  const StartSession(this.sessionId);
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class CompleteSession extends SessionsEvent {
  const CompleteSession(this.sessionId);
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class LoadSessionsInRange extends SessionsEvent {
  const LoadSessionsInRange({
    required this.start,
    required this.end,
    this.userId,
  });
  final DateTime start;
  final DateTime end;
  final String? userId;

  @override
  List<Object?> get props => [start, end, userId];
}

class RefreshSessions extends SessionsEvent {
  const RefreshSessions();
}
