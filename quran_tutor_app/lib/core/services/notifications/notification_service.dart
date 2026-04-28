import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

/// Service for handling push notifications via OneSignal
@singleton
class NotificationService {

  NotificationService()
      : _appId = const String.fromEnvironment('ONESIGNAL_APP_ID');
  final String _appId;
  bool _initialized = false;

  // Stream controllers for notification events
  final _notificationReceivedController = StreamController<dynamic>.broadcast();
  final _notificationOpenedController = StreamController<dynamic>.broadcast();

  /// Stream for received notifications
  Stream<dynamic> get notificationReceived =>
      _notificationReceivedController.stream;

  /// Stream for opened notifications
  Stream<dynamic> get notificationOpened =>
      _notificationOpenedController.stream;

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize OneSignal
    await OneSignal.initialize(_appId);

    // Set up notification handlers
    OneSignal.Notifications.addClickListener(_notificationOpenedController.add);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _notificationReceivedController.add(event.notification);
    });

    // Request permission
    await OneSignal.Notifications.requestPermission(true);

    _initialized = true;
  }

  /// Set external user ID (link to Supabase user)
  Future<void> setUser(AuthUser user) async {
    if (!_initialized) await initialize();

    // Set external user ID for targeting
    await OneSignal.login(user.id);

    // Set user tags for segmentation
    await OneSignal.User.addTags({
      'role': user.role.value,
      'status': user.status.value,
    });
  }

  /// Clear user on logout
  Future<void> clearUser() async {
    if (!_initialized) return;
    await OneSignal.logout();
  }

  /// Send notification to specific user
  /// This requires server-side API call (OneSignal REST API)
  /// For now, we just prepare the notification data
  Map<String, dynamic> prepareUserNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return {
      'include_external_user_ids': [userId],
      'headings': {'en': title},
      'contents': {'en': body},
      'data': data,
    };
  }

  /// Send notification to role segment
  Map<String, dynamic> prepareRoleNotification({
    required UserRole role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return {
      'filters': [
        {'field': 'tag', 'key': 'role', 'relation': '=', 'value': role.value},
      ],
      'headings': {'en': title},
      'contents': {'en': body},
      'data': data,
    };
  }

  /// Dispose the service
  void dispose() {
    _notificationReceivedController.close();
    _notificationOpenedController.close();
  }
}

/// Notification types
enum NotificationType {
  approval('approval', 'تم القبول'),
  rejection('rejection', 'تم الرفض'),
  sessionReminder('session_reminder', 'تذكير بالجلسة'),
  newSession('new_session', 'جلسة جديدة'),
  gradeAdded('grade_added', 'تم إضافة تقييم'),
  sessionRescheduled('session_rescheduled', 'إعادة جدولة'),
  adminNotification('admin_notification', 'إشعار إداري');

  final String value;
  final String arabicLabel;

  const NotificationType(this.value, this.arabicLabel);
}
