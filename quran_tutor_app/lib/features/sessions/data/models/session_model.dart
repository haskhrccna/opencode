import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/session.dart';

/// Data model for sessions
class SessionModel {
  final String id;
  final String teacherId;
  final String? studentId;
  final DateTime scheduledAt; // Stored in UTC
  final int durationMinutes;
  final String? topic;
  final String? notes;
  final String status;
  final DateTime createdAt; // Stored in UTC
  final DateTime? updatedAt; // Stored in UTC
  final DateTime? completedAt; // Stored in UTC
  final String? recordingUrl;
  final String? meetingLink;
  final String? location;
  final bool isOnline;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;

  SessionModel({
    required this.id,
    required this.teacherId,
    this.studentId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.topic,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.recordingUrl,
    this.meetingLink,
    this.location,
    this.isOnline = true,
    this.cancellationReason,
    this.metadata,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      studentId: data['studentId'],
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 60,
      topic: data['topic'],
      notes: data['notes'],
      status: data['status'] ?? 'scheduled',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      recordingUrl: data['recordingUrl'],
      meetingLink: data['meetingLink'],
      location: data['location'],
      isOnline: data['isOnline'] ?? true,
      cancellationReason: data['cancellationReason'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  factory SessionModel.fromSupabase(Map<String, dynamic> data) {
    return SessionModel(
      id: data['id'] ?? '',
      teacherId: data['teacher_id'] ?? '',
      studentId: data['student_id'],
      scheduledAt: DateTime.parse(data['scheduled_at'] as String),
      durationMinutes: data['duration_minutes'] ?? 60,
      topic: data['topic'],
      notes: data['notes'],
      status: data['status'] ?? 'scheduled',
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      completedAt: data['completed_at'] != null
          ? DateTime.parse(data['completed_at'] as String)
          : null,
      recordingUrl: data['recording_url'],
      meetingLink: data['meeting_link'],
      location: data['location'],
      isOnline: data['is_online'] ?? true,
      cancellationReason: data['cancellation_reason'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'studentId': studentId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationMinutes': durationMinutes,
      'topic': topic,
      'notes': notes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'recordingUrl': recordingUrl,
      'meetingLink': meetingLink,
      'location': location,
      'isOnline': isOnline,
      'cancellationReason': cancellationReason,
      'metadata': metadata,
    };
  }

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
}
