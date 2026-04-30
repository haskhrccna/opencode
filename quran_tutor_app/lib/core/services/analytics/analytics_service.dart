import 'package:injectable/injectable.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:quran_tutor_app/core/environment/app_environment.dart';

/// Service for tracking analytics events via PostHog
///
/// Only tracks events in production builds.
/// Never tracks PII or sensitive data.
@singleton
class AnalyticsService {
  AnalyticsService();

  bool _initialized = false;

  /// Initialize PostHog
  Future<void> initialize() async {
    if (_initialized) return;
    if (!AppEnvironment.enableAnalytics) return;

    final config = PostHogConfig(
      const String.fromEnvironment('POSTHOG_API_KEY'),
    );
    final host = const String.fromEnvironment('POSTHOG_HOST');
    if (host.isNotEmpty) {
      config.host = host;
    }
    await Posthog().setup(config);

    _initialized = true;
  }

  /// Identify user (only non-PII traits)
  Future<void> identifyUser({
    required String userId,
    required String role,
    required String status,
  }) async {
    if (!_shouldTrack) return;

    await Posthog().identify(
      userId: userId,
      userProperties: {
        'role': role,
        'status': status,
      },
    );
  }

  /// Reset user on logout
  Future<void> resetUser() async {
    if (!_shouldTrack) return;
    await Posthog().reset();
  }

  /// Track auth events
  Future<void> trackSignUp({required String role}) async {
    await _track('sign_up', properties: {'role': role});
  }

  Future<void> trackSignIn() async {
    await _track('sign_in');
  }

  Future<void> trackSignOut() async {
    await _track('sign_out');
  }

  Future<void> trackApprovalReceived() async {
    await _track('approval_received');
  }

  /// Track session events
  Future<void> trackSessionCreated() async {
    await _track('session_created');
  }

  Future<void> trackSessionCompleted() async {
    await _track('session_completed');
  }

  Future<void> trackSessionCancelled() async {
    await _track('session_cancelled');
  }

  /// Track grading events
  Future<void> trackGradeSubmitted() async {
    await _track('grade_submitted');
  }

  Future<void> trackAudioFeedbackRecorded() async {
    await _track('audio_feedback_recorded');
  }

  /// Track admin events
  Future<void> trackUserApproved() async {
    await _track('user_approved');
  }

  Future<void> trackUserRejected() async {
    await _track('user_rejected');
  }

  Future<void> trackReportGenerated() async {
    await _track('report_generated');
  }

  /// Track screen views
  Future<void> trackScreenView(String screenName) async {
    await _track('screen_view', properties: {'screen_name': screenName});
  }

  /// Generic track method
  Future<void> _track(
    String eventName, {
    Map<String, Object>? properties,
  }) async {
    if (!_shouldTrack) return;

    try {
      await Posthog().capture(
        eventName: eventName,
        properties: properties,
      );
    } catch (_) {
      // Silently fail analytics to not disrupt user experience
    }
  }

  bool get _shouldTrack => _initialized && AppEnvironment.enableAnalytics;
}
