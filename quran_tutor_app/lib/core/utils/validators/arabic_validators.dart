import '../../localization/app_localizations.dart';
import '../../constants/app_constants.dart';

/// Arabic-specific validators for the Quran Tutor app
/// 
/// All validation messages are now localized using translation keys
/// Format: validation.<field>_<error_type>
class ArabicValidators {
  ArabicValidators._();

  /// Validates Arabic names
  /// Allows Arabic characters and spaces only
  static String? validateArabicName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.name_arabic_required';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minNameLength) {
      return 'validation.name_arabic_min_length';
    }

    if (trimmed.length > AppConstants.maxNameLength) {
      return 'validation.name_arabic_max_length';
    }

    // Check if contains Arabic characters
    if (!AppConstants.arabicNameRegex.hasMatch(trimmed)) {
      return 'validation.name_arabic_invalid';
    }

    // Check for consecutive spaces
    if (trimmed.contains('  ')) {
      return 'validation.name_consecutive_spaces';
    }

    return null;
  }

  /// Validates English names
  /// Allows English letters and spaces only
  static String? validateEnglishName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.name_english_required';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minNameLength) {
      return 'validation.name_english_min_length';
    }

    if (trimmed.length > AppConstants.maxNameLength) {
      return 'validation.name_english_max_length';
    }

    if (!AppConstants.englishNameRegex.hasMatch(trimmed)) {
      return 'validation.name_english_invalid';
    }

    if (trimmed.contains('  ')) {
      return 'validation.name_consecutive_spaces';
    }

    return null;
  }

  /// Validates email addresses
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required';
    }

    final trimmed = value.trim().toLowerCase();

    if (!AppConstants.emailRegex.hasMatch(trimmed)) {
      return 'validation.email_invalid';
    }

    return null;
  }

  /// Validates phone numbers (Saudi format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الجوال مطلوب';
    }

    final cleanPhone = value.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (!AppConstants.phoneRegex.hasMatch(cleanPhone)) {
      return 'رقم الجوال يجب أن يكون بصيغة +9665XXXXXXXX أو 05XXXXXXXX';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'validation.password_min_length';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'validation.password_max_length';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'validation.password_uppercase';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'validation.password_lowercase';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'validation.password_number';
    }

    // Special character check - only recommend, don't require
    // This matches the regex in AppConstants that makes special chars optional
    // We don't return an error here, UI can show a hint instead

    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'validation.required';
    }

    if (value != password) {
      return 'validation.password_mismatch';
    }

    return null;
  }

  /// Validates age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation.age_required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'validation.age_invalid';
    }

    if (age < AppConstants.minAge) {
      return 'validation.age_min';
    }

    if (age > AppConstants.maxAge) {
      return 'validation.age_max';
    }

    return null;
  }

  /// Validates a required field
  static String? validateRequired(String? value, {String fieldKey = 'validation.required'}) {
    if (value == null || value.trim().isEmpty) {
      return fieldKey;
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, {String fieldKey = 'validation.min_length'}) {
    if (value == null || value.length < minLength) {
      return fieldKey;
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, {String fieldKey = 'validation.max_length'}) {
    if (value != null && value.length > maxLength) {
      return fieldKey;
    }
    return null;
  }

  /// Validates teacher invite code
  static String? validateInviteCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.invite_code_required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 6) {
      return 'validation.invite_code_min_length';
    }

    // Invite codes are typically alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmed)) {
      return 'validation.invite_code_invalid';
    }

    return null;
  }

  /// Validates bio/description text
  static String? validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Bio is optional
    }

    if (value.length > AppConstants.maxBioLength) {
      return 'validation.bio_max_length';
    }

    return null;
  }

  /// Validates a URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final trimmed = value.trim();

    final urlPattern = RegExp(
      r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(trimmed)) {
      return 'validation.url_invalid';
    }

    return null;
  }

  /// Get localized validation message with arguments
  /// 
  /// Usage:
  /// ```dart
  /// final localizedError = ArabicValidators.getLocalizedMessage(
  ///   context,
  ///   errorKey,
  ///   args: {'min': '8', 'max': '32'},
  /// );
  /// ```
  static String getLocalizedMessage(
    context,
    String key, {
    Map<String, String>? args,
  }) {
    final localizations = AppLocalizations.of(context);
    return localizations.translate(key, args: args);
  }
}

/// Form input validation result
class ValidationResult {
  final bool isValid;
  final String? errorKey;
  final Map<String, String>? args;

  const ValidationResult._({
    required this.isValid,
    this.errorKey,
    this.args,
  });

  factory ValidationResult.valid() => const ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String key, {Map<String, String>? args}) =>
      ValidationResult._(
        isValid: false,
        errorKey: key,
        args: args,
      );

  /// Get localized error message
  String getLocalizedMessage(context) {
    if (isValid || errorKey == null) return '';
    final localizations = AppLocalizations.of(context);
    return localizations.translate(errorKey!, args: args);
  }
}

/// Extension methods for string validation
extension StringValidation on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  bool get isValidEmail =>
      isNotNullOrEmpty && AppConstants.emailRegex.hasMatch(this!);

  bool get isValidPhone =>
      isNotNullOrEmpty && AppConstants.phoneRegex.hasMatch(this!);

  bool get isValidArabicName =>
      isNotNullOrEmpty && AppConstants.arabicNameRegex.hasMatch(this!);

  bool get isValidEnglishName =>
      isNotNullOrEmpty && AppConstants.englishNameRegex.hasMatch(this!);

  /// Check if password meets all requirements
  bool get isValidPassword =>
      isNotNullOrEmpty && AppConstants.passwordRegex.hasMatch(this!);
}
