import 'package:flutter/material.dart';
import '../environment/app_environment.dart';

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'Quran Tutor';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Locales
  static const Locale defaultLocale = Locale('ar');
  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    Locale('en'), // English (fallback)
  ];
  static const String translationsPath = 'assets/lang';

  // API Endpoints - Now configured via AppEnvironment
  static String get baseUrl => AppEnvironment.baseUrl;
  static int get apiTimeout => AppEnvironment.apiTimeout;
  static int get apiReceiveTimeout => AppEnvironment.apiReceiveTimeout;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'sessions';
  static const String gradesCollection = 'grades';
  static const String teachersCollection = 'teachers';
  static const String studentsCollection = 'students';
  static const String notificationsCollection = 'notifications';
  static const String auditLogsCollection = 'audit_logs';
  static const String teacherInvitesTable = 'teacher_invites';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minAge = 5;
  static const int maxAge = 100;
  static const int maxBioLength = 500;

  // Session Duration
  static const List<int> sessionDurations = [30, 45, 60, 90, 120]; // minutes
  static const int defaultSessionDuration = 60;

  // Grading
  static const int minGrade = 1;
  static const int maxGrade = 5;

  // Notification Channels
  static const String sessionReminderChannel = 'session_reminders';
  static const String approvalChannel = 'approvals';
  static const String generalChannel = 'general';

  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 2.0;
  static const double minTouchTarget = 48.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String serverDateFormat = 'yyyy-MM-dd';
  static const String serverDateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^(\+966|0)5[0-9]{8}$', // Saudi format: +9665XXXXXXXX or 05XXXXXXXX
  );
  static final RegExp arabicNameRegex = RegExp(
    r'^[\u0600-\u06FF\s]+$', // Arabic characters and spaces
    unicode: true,
  );
  static final RegExp englishNameRegex = RegExp(
    r'^[a-zA-Z\s]+$',
  );
  
  /// Password requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - Special characters are RECOMMENDED but optional
  ///
  /// This allows passwords like:
  /// - Password123 (letters + numbers only)
  /// - Password123! (with special characters)
  /// - MyPass1 (minimum 8, mixed case + number)
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
  );

  /// Check if password has at least one special character
  static final RegExp passwordSpecialCharRegex = RegExp(
    r'[!@#$%^&*(),.?":{}|<>]',
  );

  /// Password validation messages
  static const String passwordMinLengthMessage = 
      'Password must be at least 8 characters';
  static const String passwordMaxLengthMessage = 
      'Password must not exceed 32 characters';
  static const String passwordUppercaseMessage = 
      'Password must contain at least one uppercase letter';
  static const String passwordLowercaseMessage = 
      'Password must contain at least one lowercase letter';
  static const String passwordNumberMessage = 
      'Password must contain at least one number';
  static const String passwordSpecialCharRecommendedMessage = 
      'Tip: Adding special characters makes your password stronger';
  static const String passwordHint = 
      'Use at least 8 characters with uppercase, lowercase, and numbers';
}

/// User roles in the application
enum UserRole {
  student('student', 'طالب'),
  teacher('teacher', 'معلم'),
  admin('admin', 'مدير');

  final String value;
  final String arabicLabel;

  const UserRole(this.value, this.arabicLabel);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}

/// User account status
enum UserStatus {
  pending('pending', 'قيد الانتظار'),
  approved('approved', 'تم القبول'),
  rejected('rejected', 'مرفوض'),
  suspended('suspended', 'موقوف');

  final String value;
  final String arabicLabel;

  const UserStatus(this.value, this.arabicLabel);

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.pending,
    );
  }
}

/// Session status
enum SessionStatus {
  scheduled('scheduled', 'مجدول'),
  inProgress('in_progress', 'جاري'),
  completed('completed', 'مكتمل'),
  cancelled('cancelled', 'ملغي'),
  rescheduled('rescheduled', 'تم إعادة الجدولة');

  final String value;
  final String arabicLabel;

  const SessionStatus(this.value, this.arabicLabel);

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SessionStatus.scheduled,
    );
  }
}

/// Grading categories
enum GradingCategory {
  memorization('memorization', 'الحفظ'),
  tajweed('tajweed', 'التجويد'),
  mastery('mastery', 'الإتقان'),
  consistency('consistency', 'المثابرة');

  final String value;
  final String arabicLabel;

  const GradingCategory(this.value, this.arabicLabel);
}

/// Notification types
enum NotificationType {
  approval('approval', 'قبول'),
  sessionReminder('session_reminder', 'تذكير بالجلسة'),
  gradeAdded('grade_added', 'تم إضافة تقييم'),
  sessionRescheduled('session_rescheduled', 'إعادة جدولة'),
  system('system', 'نظام');

  final String value;
  final String arabicLabel;

  const NotificationType(this.value, this.arabicLabel);
}
