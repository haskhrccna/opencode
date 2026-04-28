import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling push notifications (OneSignal) and local notifications
@singleton
class NotificationService {

  NotificationService()
      : _appId = const String.fromEnvironment('ONESIGNAL_APP_ID');
  final String _appId;
  bool _initialized = false;

  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Stream controllers for notification events
  final _notificationReceivedController = StreamController<dynamic>.broadcast();
  final _notificationOpenedController = StreamController<dynamic>.broadcast();
  final _localNotificationTapController = StreamController<String?>.broadcast();

  /// Stream for received push notifications
  Stream<dynamic> get notificationReceived =>
      _notificationReceivedController.stream;

  /// Stream for opened push notifications
  Stream<dynamic> get notificationOpened =>
      _notificationOpenedController.stream;

  /// Stream for local notification taps (payload)
  Stream<String?> get localNotificationTap =>
      _localNotificationTapController.stream;

  /// Initialize both OneSignal and local notifications
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data for scheduled notifications
    tz_data.initializeTimeZones();

    // Initialize OneSignal
    await _initializeOneSignal();

    // Initialize local notifications
    await _initializeLocalNotifications();

    _initialized = true;
  }

  Future<void> _initializeOneSignal() async {
    await OneSignal.initialize(_appId);

    OneSignal.Notifications.addClickListener(_notificationOpenedController.add);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _notificationReceivedController.add(event.notification);
    });

    await OneSignal.Notifications.requestPermission(true);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _localNotificationTapController.add(response.payload);
      },
    );

    // Request permissions on Android 13+
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Set external user ID (link to Supabase user)
  Future<void> setUser(AuthUser user) async {
    if (!_initialized) await initialize();

    await OneSignal.login(user.id);
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

  /// Schedule a local reminder for an upcoming session
  Future<void> scheduleSessionReminder({
    required int id,
    required String sessionId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await initialize();

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_reminders',
          'Session Reminders',
          channelDescription: 'Reminders for upcoming Quran tutoring sessions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'session:$sessionId',
    );
  }

  /// Schedule a reminder 15 minutes before a session
  Future<void> scheduleSessionPreReminder({
    required int id,
    required String sessionId,
    required String title,
    required DateTime sessionDate,
  }) async {
    final reminderTime = sessionDate.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;

    await scheduleSessionReminder(
      id: id,
      sessionId: sessionId,
      title: 'تذكير بالجلسة',
      body: title,
      scheduledDate: reminderTime,
    );
  }

  /// Cancel a specific scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Show an immediate local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_notifications',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Prepare push notification data for OneSignal REST API
  Map<String, dynamic> prepareUserNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return {
      'include_external_user_ids': [userId],
      'headings': {'en': title, 'ar': title},
      'contents': {'en': body, 'ar': body},
      'data': data,
    };
  }

  /// Prepare role-based push notification
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
      'headings': {'en': title, 'ar': title},
      'contents': {'en': body, 'ar': body},
      'data': data,
    };
  }

  /// Dispose the service
  void dispose() {
    _notificationReceivedController.close();
    _notificationOpenedController.close();
    _localNotificationTapController.close();
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
