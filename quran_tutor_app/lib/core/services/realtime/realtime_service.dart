import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/sessions/data/models/session_model.dart';

/// Service for handling Supabase Realtime subscriptions
@singleton
class RealtimeService {
  final SupabaseClient _supabase;

  // Stream controllers for different events
  final _sessionUpdatesController = StreamController<SessionUpdate>.broadcast();
  final _adminNotificationsController = StreamController<AdminNotification>.broadcast();
  final _studentJoinsController = StreamController<StudentJoin>.broadcast();

  RealtimeService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Stream for session status updates
  Stream<SessionUpdate> get sessionUpdates => _sessionUpdatesController.stream;

  /// Stream for admin notifications (e.g., new registrations)
  Stream<AdminNotification> get adminNotifications => _adminNotificationsController.stream;

  /// Stream for student joins to sessions (teacher view)
  Stream<StudentJoin> get studentJoins => _studentJoinsController.stream;

  /// Subscribe to session updates for a specific user
  /// 
  /// Emits updates when session status changes (in-progress, completed, etc.)
  void subscribeToSessionUpdates(String userId) {
    _supabase
        .from('sessions')
        .stream(primaryKey: ['id'])
        .eq('teacher_id', userId)
        .listen((data) {
          for (final change in data) {
            _sessionUpdatesController.add(SessionUpdate(
              sessionId: change['id'] as String,
              status: change['status'] as String,
              studentId: change['student_id'] as String?,
              updatedAt: DateTime.parse(change['updated_at'] as String),
            ));
          }
        });

    // Also listen for student sessions
    _supabase
        .from('sessions')
        .stream(primaryKey: ['id'])
        .eq('student_id', userId)
        .listen((data) {
          for (final change in data) {
            _sessionUpdatesController.add(SessionUpdate(
              sessionId: change['id'] as String,
              status: change['status'] as String,
              studentId: change['student_id'] as String?,
              updatedAt: DateTime.parse(change['updated_at'] as String),
            ));
          }
        });
  }

  /// Subscribe to admin notifications
  /// 
  /// Emits when new registrations need approval
  void subscribeToAdminNotifications() {
    _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .listen((data) {
          for (final change in data) {
            _adminNotificationsController.add(AdminNotification(
              type: AdminNotificationType.newRegistration,
              userId: change['id'] as String,
              userName: change['english_name'] as String? ??
                  change['arabic_name'] as String? ??
                  'Unknown',
              role: change['role'] as String,
              createdAt: DateTime.parse(change['created_at'] as String),
            ));
          }
        });
  }

  /// Subscribe to student joins for a teacher
  /// 
  /// Emits when students join sessions
  void subscribeToStudentJoins(String teacherId) {
    _supabase
        .from('sessions')
        .stream(primaryKey: ['id'])
        .eq('teacher_id', teacherId)
        .listen((data) {
          for (final change in data) {
            // Check if student_id was updated (student joined)
            if (change['student_id'] != null) {
              _studentJoinsController.add(StudentJoin(
                sessionId: change['id'] as String,
                studentId: change['student_id'] as String,
                studentName: change['student_name'] as String? ?? 'Unknown',
                joinedAt: DateTime.now(),
              ));
            }
          }
        });
  }

  /// Unsubscribe from all channels
  void unsubscribeAll() {
    _supabase.removeAllChannels();
  }

  /// Dispose the service
  void dispose() {
    _sessionUpdatesController.close();
    _adminNotificationsController.close();
    _studentJoinsController.close();
    unsubscribeAll();
  }
}

/// Session update event
class SessionUpdate {
  final String sessionId;
  final String status;
  final String? studentId;
  final DateTime updatedAt;

  SessionUpdate({
    required this.sessionId,
    required this.status,
    this.studentId,
    required this.updatedAt,
  });
}

/// Admin notification event
class AdminNotification {
  final AdminNotificationType type;
  final String userId;
  final String userName;
  final String role;
  final DateTime createdAt;

  AdminNotification({
    required this.type,
    required this.userId,
    required this.userName,
    required this.role,
    required this.createdAt,
  });
}

enum AdminNotificationType {
  newRegistration,
  userApproved,
  userRejected,
}

/// Student join event
class StudentJoin {
  final String sessionId;
  final String studentId;
  final String studentName;
  final DateTime joinedAt;

  StudentJoin({
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.joinedAt,
  });
}
