import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// Session entity representing a Quran learning session
///
/// **CRITICAL**: All timestamps are stored in UTC and converted
/// to local time for display only.
class Session extends Equatable {

  const Session({
    required this.id,
    required this.teacherId,
    required this.scheduledAt, required this.status, required this.createdAt, this.studentId,
    this.durationMinutes = 60,
    this.topic,
    this.notes,
    this.updatedAt,
    this.completedAt,
    this.recordingUrl,
    this.meetingLink,
    this.location,
    this.isOnline = true,
    this.metadata,
  });

  /// Create empty session
  factory Session.empty() => Session(
        id: '',
        teacherId: '',
        scheduledAt: DateTime.now().toUtc(),
        status: SessionStatus.scheduled,
        createdAt: DateTime.now().toUtc(),
      );
  final String id;
  final String teacherId;
  final String? studentId;
  final DateTime scheduledAt; // Stored in UTC
  final int durationMinutes;
  final String? topic;
  final String? notes;
  final SessionStatus status;
  final DateTime createdAt; // Stored in UTC
  final DateTime? updatedAt; // Stored in UTC
  final DateTime? completedAt; // Stored in UTC
  final String? recordingUrl;
  final String? meetingLink;
  final String? location;
  final bool isOnline;
  final Map<String, dynamic>? metadata;

  /// Get local time for display
  DateTime get localScheduledAt => scheduledAt.toLocal();

  /// Get local time for display
  DateTime? get localCompletedAt => completedAt?.toLocal();

  /// Check if session is upcoming
  bool get isUpcoming =>
      status == SessionStatus.scheduled && scheduledAt.isAfter(DateTime.now().toUtc());

  /// Check if session is in progress
  bool get isInProgress => status == SessionStatus.inProgress;

  /// Check if session is completed
  bool get isCompleted => status == SessionStatus.completed;

  /// Check if session is cancelled
  bool get isCancelled => status == SessionStatus.cancelled;

  /// Get end time in UTC
  DateTime get endAt => scheduledAt.add(Duration(minutes: durationMinutes));

  /// Get local end time for display
  DateTime get localEndAt => endAt.toLocal();

  /// Check if session is happening now
  bool get isNow {
    final now = DateTime.now().toUtc();
    return now.isAfter(scheduledAt) && now.isBefore(endAt);
  }

  /// Format scheduled time for display in local timezone
  String get formattedLocalTime {
    final local = localScheduledAt;
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// Get session duration as readable string
  String get durationText {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) {
      return '$hours hr';
    }
    return '$hours hr $mins min';
  }

  Session copyWith({
    String? id,
    String? teacherId,
    String? studentId,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? topic,
    String? notes,
    SessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? recordingUrl,
    String? meetingLink,
    String? location,
    bool? isOnline,
    Map<String, dynamic>? metadata,
  }) {
    return Session(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topic: topic ?? this.topic,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        studentId,
        scheduledAt,
        durationMinutes,
        topic,
        notes,
        status,
        createdAt,
        updatedAt,
        completedAt,
        recordingUrl,
        meetingLink,
        location,
        isOnline,
        metadata,
      ];
}
