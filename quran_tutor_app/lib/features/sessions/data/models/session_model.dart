import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';

/// Data model for sessions
class SessionModel {

  SessionModel({
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
    this.cancellationReason,
    this.metadata,
  });

  factory SessionModel.fromSupabase(Map<String, dynamic> data) {
    return SessionModel(
      id: (data['id'] as String?) ?? '',
      teacherId: (data['teacher_id'] as String?) ?? '',
      studentId: data['student_id'] as String?,
      scheduledAt: DateTime.parse(data['scheduled_at'] as String),
      durationMinutes: (data['duration_minutes'] as num?)?.toInt() ?? 60,
      topic: data['topic'] as String?,
      notes: data['notes'] as String?,
      status: (data['status'] as String?) ?? 'scheduled',
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      completedAt: data['completed_at'] != null
          ? DateTime.parse(data['completed_at'] as String)
          : null,
      recordingUrl: data['recording_url'] as String?,
      meetingLink: data['meeting_link'] as String?,
      location: data['location'] as String?,
      isOnline: (data['is_online'] as bool?) ?? true,
      cancellationReason: data['cancellation_reason'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  factory SessionModel.fromEntity(Session entity) {
    return SessionModel(
      id: entity.id,
      teacherId: entity.teacherId,
      studentId: entity.studentId,
      scheduledAt: entity.scheduledAt, // Already UTC
      durationMinutes: entity.durationMinutes,
      topic: entity.topic,
      notes: entity.notes,
      status: entity.status.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      completedAt: entity.completedAt,
      recordingUrl: entity.recordingUrl,
      meetingLink: entity.meetingLink,
      location: entity.location,
      isOnline: entity.isOnline,
      metadata: entity.metadata,
    );
  }
  final String id;
  final String teacherId;
  final String? studentId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? topic;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? recordingUrl;
  final String? meetingLink;
  final String? location;
  final bool isOnline;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toSupabase() {
    // CRITICAL: All timestamps stored in UTC
    return {
      'id': id,
      'teacher_id': teacherId,
      'student_id': studentId,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'topic': topic,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'completed_at': completedAt?.toUtc().toIso8601String(),
      'recording_url': recordingUrl,
      'meeting_link': meetingLink,
      'location': location,
      'is_online': isOnline,
      'cancellation_reason': cancellationReason,
      'metadata': metadata,
    };
  }

  Session toEntity() {
    return Session(
      id: id,
      teacherId: teacherId,
      studentId: studentId,
      scheduledAt: scheduledAt, // Already UTC from database
      durationMinutes: durationMinutes,
      topic: topic,
      notes: notes,
      status: SessionStatus.fromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      recordingUrl: recordingUrl,
      meetingLink: meetingLink,
      location: location,
      isOnline: isOnline,
      metadata: metadata,
    );
  }
}
