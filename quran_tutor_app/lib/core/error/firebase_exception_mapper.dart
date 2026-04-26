import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';
import 'failures.dart';

/// Maps Firebase exceptions to domain Failures with localized messages
/// 
/// This class centralizes the translation of Firebase error codes
/// to user-friendly error messages in both Arabic and English
class FirebaseExceptionMapper {
  FirebaseExceptionMapper._();

  /// Map Firebase Auth exceptions to AuthFailure
  static Failure mapAuthException(FirebaseAuthException exception) {
    final errorInfo = _authErrorCodes[exception.code] ??
        _ErrorInfo(
          arMessage: 'حدث خطأ غير متوقع',
          enMessage: 'An unexpected error occurred',
          code: exception.code,
        );

    return AuthFailure(
      message: errorInfo.localizedMessage,
      code: errorInfo.code,
    );
  }

  /// Map Firebase Auth exception code to localized message directly
  static String getLocalizedMessage(String code, {bool arabic = true}) {
    final errorInfo = _authErrorCodes[code];
    if (errorInfo == null) {
      return arabic
          ? 'حدث خطأ غير متوقع'
          : 'An unexpected error occurred';
    }
    return arabic ? errorInfo.arMessage : errorInfo.enMessage;
  }

  /// Check if the error is retryable
  static bool isRetryable(String code) {
    final retryableCodes = [
      'network-request-failed',
      'timeout',
      'unavailable',
    ];
    return retryableCodes.contains(code);
  }

  /// Check if the error requires user action
  static bool requiresUserAction(String code) {
    final actionableCodes = [
      'email-already-in-use',
      'invalid-email',
      'weak-password',
      'user-disabled',
      'user-not-found',
      'wrong-password',
      'invalid-credential',
      'invalid-verification-code',
      'invalid-verification-id',
    ];
    return actionableCodes.contains(code);
  }

  /// Firebase Auth error codes mapping
  static const Map<String, _ErrorInfo> _authErrorCodes = {
    // User not found
    'user-not-found': _ErrorInfo(
      arMessage: 'لم يتم العثور على حساب بهذا البريد الإلكتروني',
      enMessage: 'No account found with this email',
      code: 'user_not_found',
    ),
    // Wrong password
    'wrong-password': _ErrorInfo(
      arMessage: 'كلمة المرور غير صحيحة',
      enMessage: 'Incorrect password',
      code: 'wrong_password',
    ),
    // Email already in use
    'email-already-in-use': _ErrorInfo(
      arMessage: 'هذا البريد الإلكتروني مستخدم بالفعل',
      enMessage: 'This email is already in use',
      code: 'email_already_in_use',
    ),
    // Invalid email
    'invalid-email': _ErrorInfo(
      arMessage: 'البريد الإلكتروني غير صحيح',
      enMessage: 'Invalid email address',
      code: 'invalid_email',
    ),
    // Weak password
    'weak-password': _ErrorInfo(
      arMessage: 'كلمة المرور ضعيفة جداً',
      enMessage: 'Password is too weak',
      code: 'weak_password',
    ),
    // User disabled
    'user-disabled': _ErrorInfo(
      arMessage: 'تم تعطيل هذا الحساب',
      enMessage: 'This account has been disabled',
      code: 'user_disabled',
    ),
    // Too many requests
    'too-many-requests': _ErrorInfo(
      arMessage: 'محاولات كثيرة، يرجى المحاولة لاحقاً',
      enMessage: 'Too many attempts, please try again later',
      code: 'too_many_requests',
    ),
    // Operation not allowed
    'operation-not-allowed': _ErrorInfo(
      arMessage: 'هذه العملية غير مسموح بها',
      enMessage: 'This operation is not allowed',
      code: 'operation_not_allowed',
    ),
    // Invalid credential
    'invalid-credential': _ErrorInfo(
      arMessage: 'بيانات الاعتماد غير صالحة أو منتهية الصلاحية',
      enMessage: 'Invalid or expired credentials',
      code: 'invalid_credential',
    ),
    // Network request failed
    'network-request-failed': _ErrorInfo(
      arMessage: 'فشل الاتصال بالشبكة، يرجى التحقق من الإنترنت',
      enMessage: 'Network connection failed, please check your internet',
      code: 'network_request_failed',
    ),
    // Requires recent login
    'requires-recent-login': _ErrorInfo(
      arMessage: 'يجب تسجيل الدخول مرة أخرى لإكمال هذه العملية',
      enMessage: 'Please sign in again to complete this operation',
      code: 'requires_recent_login',
    ),
    // Credential already in use
    'credential-already-in-use': _ErrorInfo(
      arMessage: 'بيانات الاعتماد هذه مستخدمة بالفعل',
      enMessage: 'These credentials are already in use',
      code: 'credential_already_in_use',
    ),
    // Invalid verification code
    'invalid-verification-code': _ErrorInfo(
      arMessage: 'رمز التحقق غير صحيح',
      enMessage: 'Invalid verification code',
      code: 'invalid_verification_code',
    ),
    // Invalid verification ID
    'invalid-verification-id': _ErrorInfo(
      arMessage: 'معرف التحقق غير صحيح',
      enMessage: 'Invalid verification ID',
      code: 'invalid_verification_id',
    ),
    // Session expired
    'session-expired': _ErrorInfo(
      arMessage: 'انتهت الجلسة، يرجى المحاولة مرة أخرى',
      enMessage: 'Session expired, please try again',
      code: 'session_expired',
    ),
    // Quota exceeded
    'quota-exceeded': _ErrorInfo(
      arMessage: 'تم تجاوز الحصة المخصصة، يرجى المحاولة لاحقاً',
      enMessage: 'Quota exceeded, please try again later',
      code: 'quota_exceeded',
    ),
    // App not authorized
    'app-not-authorized': _ErrorInfo(
      arMessage: 'التطبيق غير مصرح له',
      enMessage: 'App not authorized',
      code: 'app_not_authorized',
    ),
    // Expired action code
    'expired-action-code': _ErrorInfo(
      arMessage: 'انتهت صلاحية الرمز',
      enMessage: 'Code has expired',
      code: 'expired_action_code',
    ),
    // Invalid action code
    'invalid-action-code': _ErrorInfo(
      arMessage: 'الرمز غير صالح',
      enMessage: 'Invalid code',
      code: 'invalid_action_code',
    ),
    // User token expired
    'user-token-expired': _ErrorInfo(
      arMessage: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
      enMessage: 'Session expired, please sign in again',
      code: 'user_token_expired',
    ),
    // Web storage unsupported
    'web-storage-unsupported': _ErrorInfo(
      arMessage: 'متصفحك لا يدعم التخزين المحلي',
      enMessage: 'Your browser does not support local storage',
      code: 'web_storage_unsupported',
    ),
    // Invalid API key
    'invalid-api-key': _ErrorInfo(
      arMessage: 'مفتاح API غير صالح',
      enMessage: 'Invalid API key',
      code: 'invalid_api_key',
    ),
    // App not found
    'app-not-found': _ErrorInfo(
      arMessage: 'التطبيق غير موجود',
      enMessage: 'App not found',
      code: 'app_not_found',
    ),
    // Keychain error (iOS specific)
    'keychain-error': _ErrorInfo(
      arMessage: 'خطأ في الوصول إلى المفتاح',
      enMessage: 'Keychain access error',
      code: 'keychain_error',
    ),
    // Internal error
    'internal-error': _ErrorInfo(
      arMessage: 'حدث خطأ داخلي، يرجى المحاولة لاحقاً',
      enMessage: 'An internal error occurred, please try again later',
      code: 'internal_error',
    ),
  };
}

/// Error info holder
class _ErrorInfo {
  final String arMessage;
  final String enMessage;
  final String code;

  const _ErrorInfo({
    required this.arMessage,
    required this.enMessage,
    required this.code,
  });

  String get localizedMessage => 
      AppConstants.defaultLocale.languageCode == 'ar' ? arMessage : enMessage;
}
