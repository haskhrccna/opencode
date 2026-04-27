import 'package:equatable/equatable.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessions extends SessionsEvent {
  final String? userId;

  const LoadSessions({this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadTeacherSessions extends SessionsEvent {
  final String teacherId;

  const LoadTeacherSessions(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class LoadStudentSessions extends SessionsEvent {
  final String studentId;

  const LoadStudentSessions(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadAllSessions extends SessionsEvent {
  const LoadAllSessions();
}

class LoadUpcomingSessions extends SessionsEvent {
  final String? userId;

  const LoadUpcomingSessions({this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadPastSessions extends SessionsEvent {
  final String? userId;

  const LoadPastSessions({this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetSession extends SessionsEvent {
  final String sessionId;

  const GetSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class CreateSession extends SessionsEvent {
  final String teacherId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? topic;
  final String? notes;
  final String? location;
  final bool isOnline;

  const CreateSession({
    required this.teacherId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.topic,
    this.notes,
    this.location,
    this.isOnline = true,
  });

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
  final String sessionId;
  final String studentId;

  const AssignStudent({
    required this.sessionId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [sessionId, studentId];
}

class UnassignStudent extends SessionsEvent {
  final String sessionId;

  const UnassignStudent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class UpdateSession extends SessionsEvent {
  final String sessionId;
  final DateTime? scheduledAt;
  final int? durationMinutes;
  final String? topic;
  final String? notes;
  final String? location;
  final bool? isOnline;

  const UpdateSession({
    required this.sessionId,
    this.scheduledAt,
    this.durationMinutes,
    this.topic,
    this.notes,
    this.location,
    this.isOnline,
  });

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
  final String sessionId;
  final String? reason;

  const CancelSession({
    required this.sessionId,
    this.reason,
  });

  @override
  List<Object?> get props => [sessionId, reason];
}

class RescheduleSession extends SessionsEvent {
  final String sessionId;
  final DateTime newScheduledAt;

  const RescheduleSession({
    required this.sessionId,
    required this.newScheduledAt,
  });

  @override
  List<Object?> get props => [sessionId, newScheduledAt];
}

class StartSession extends SessionsEvent {
  final String sessionId;

  const StartSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class CompleteSession extends SessionsEvent {
  final String sessionId;

  const CompleteSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class LoadSessionsInRange extends SessionsEvent {
  final DateTime start;
  final DateTime end;
  final String? userId;

  const LoadSessionsInRange({
    required this.start,
    required this.end,
    this.userId,
  });

  @override
  List<Object?> get props => [start, end, userId];
}

class RefreshSessions extends SessionsEvent {
  const RefreshSessions();
}
