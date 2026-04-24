import '../../constants/app_constants.dart';

/// Arabic-specific validators for the Quran Tutor app
class ArabicValidators {
  ArabicValidators._();

  /// Validates Arabic names
  /// Allows Arabic characters and spaces only
  static String? validateArabicName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minNameLength) {
      return 'الاسم يجب أن يحتوي على ${AppConstants.minNameLength} أحرف على الأقل';
    }

    if (trimmed.length > AppConstants.maxNameLength) {
      return 'الاسم يجب أن لا يتجاوز ${AppConstants.maxNameLength} حرف';
    }

    // Check if contains Arabic characters
    if (!AppConstants.arabicNameRegex.hasMatch(trimmed)) {
      return 'الاسم يجب أن يكون باللغة العربية فقط';
    }

    // Check for consecutive spaces
    if (trimmed.contains('  ')) {
      return 'الاسم يحتوي على مسافات متتالية';
    }

    return null;
  }

  /// Validates English names
  /// Allows English letters and spaces only
  static String? validateEnglishName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم بالإنجليزية مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.minNameLength) {
      return 'الاسم يجب أن يحتوي على ${AppConstants.minNameLength} أحرف على الأقل';
    }

    if (trimmed.length > AppConstants.maxNameLength) {
      return 'الاسم يجب أن لا يتجاوز ${AppConstants.maxNameLength} حرف';
    }

    if (!AppConstants.englishNameRegex.hasMatch(trimmed)) {
      return 'الاسم يجب أن يكون بالإنجليزية فقط';
    }

    if (trimmed.contains('  ')) {
      return 'الاسم يحتوي على مسافات متتالية';
    }

    return null;
  }

  /// Validates email addresses
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final trimmed = value.trim().toLowerCase();

    if (!AppConstants.emailRegex.hasMatch(trimmed)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Validates phone numbers (Saudi format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الجوال مطلوب';
    }

    final trimmed = value.trim();

    // Remove spaces and dashes
    final cleanPhone = trimmed.replaceAll(RegExp(r'[\s-]'), '');

    // Check if starts with +966 or 05
    if (!cleanPhone.startsWith('+966') && !cleanPhone.startsWith('05') && !cleanPhone.startsWith('00966')) {
      return 'رقم الجوال يجب أن يبدأ بـ +966 أو 05';
    }

    // Validate length
    final length = cleanPhone.length;
    if ((cleanPhone.startsWith('+966') && length != 13) ||
        (cleanPhone.startsWith('05') && length != 10) ||
        (cleanPhone.startsWith('00966') && length != 14)) {
      return 'رقم الجوال غير صحيح';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'كلمة المرور يجب أن لا تتجاوز ${AppConstants.maxPasswordLength} حرف';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'يجب أن تحتوي على رقم واحد على الأقل';
    }

    // Check for special character (optional but recommended)
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'يجب أن تحتوي على رمز خاص واحد على الأقل (!@#$%^&*...)'; // optional
    }

    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  /// Validates age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'العمر مطلوب';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'العمر يجب أن يكون رقماً';
    }

    if (age < AppConstants.minAge) {
      return 'العمر يجب أن يكون ${AppConstants.minAge} سنوات على الأقل';
    }

    if (age > AppConstants.maxAge) {
      return 'العمر يجب أن لا يتجاوز ${AppConstants.maxAge} سنة';
    }

    return null;
  }

  /// Validates a required field
  static String? validateRequired(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'النص'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName يجب أن يكون $minLength أحرف على الأقل';
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'النص'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName يجب أن لا يتجاوز $maxLength حرف';
    }
    return null;
  }

  /// Validates teacher invite code
  static String? validateInviteCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رمز الدعوة مطلوب';
    }

    final trimmed = value.trim();

    if (trimmed.length < 6) {
      return 'رمز الدعوة يجب أن يكون 6 أحرف على الأقل';
    }

    // Invite codes are typically alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmed)) {
      return 'رمز الدعوة يجب أن يحتوي على أحرف وأرقام فقط';
    }

    return null;
  }

  /// Validates bio/description text
  static String? validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Bio is optional
    }

    if (value.length > AppConstants.maxBioLength) {
      return 'النبذة يجب أن لا تتجاوز ${AppConstants.maxBioLength} حرف';
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
      return 'الرابط غير صحيح';
    }

    return null;
  }
}

/// Form input validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult._(isValid: false, errorMessage: message);
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
}
