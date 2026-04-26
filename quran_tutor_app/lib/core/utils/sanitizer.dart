import '../constants/app_constants.dart';

/// Input sanitizer for security and data integrity
///
/// This class sanitizes all string inputs before persistence
/// to prevent injection attacks and ensure data quality.
class Sanitizer {
  Sanitizer._();

  /// Strip control characters from strings
  ///
  /// Removes invisible/control characters (0x00-0x1F and 0x7F)
  /// that could be used for injection attacks
  static String stripControlCharacters(String input) {
    if (input.isEmpty) return input;

    // Remove control characters (0x00-0x1F and 0x7F)
    return input.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      '',
    );
  }

  /// Remove HTML/XML tags to prevent XSS
  static String stripHtmlTags(String input) {
    if (input.isEmpty) return input;
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Remove JavaScript event handlers
  static String stripEventHandlers(String input) {
    if (input.isEmpty) return input;
    // Simplified pattern to remove event handlers like onClick, onLoad, etc.
    return input.replaceAll(
      RegExp(r"\s+(on\w+)\s*=\s*['\"][^'\"]*['\"]", caseSensitive: false),
      '',
    );
  }

  /// Sanitize email address
  static String sanitizeEmail(String email) {
    if (email.isEmpty) return email;

    var sanitized = email.trim().toLowerCase();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);

    // Validate email format
    if (!AppConstants.emailRegex.hasMatch(sanitized)) {
      throw ArgumentError('Invalid email format');
    }

    return sanitized;
  }

  /// Sanitize name with length limit
  static String sanitizeName(
    String name, {
    int maxLength = AppConstants.maxNameLength,
    bool allowArabic = true,
    bool allowEnglish = true,
  }) {
    if (name.isEmpty) return name;

    var sanitized = name.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    sanitized = stripEventHandlers(sanitized);

    // Length limit
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    // Validate against allow-lists
    if (allowArabic && AppConstants.arabicNameRegex.hasMatch(sanitized)) {
      return sanitized;
    }

    if (allowEnglish && AppConstants.englishNameRegex.hasMatch(sanitized)) {
      return sanitized;
    }

    throw ArgumentError(
      'Name must contain only Arabic or English characters',
    );
  }

  /// Sanitize password (don't store sanitized, just validate)
  static String sanitizePassword(String password) {
    if (password.isEmpty) return password;

    var sanitized = password;
    sanitized = stripControlCharacters(sanitized);

    // Remove null bytes
    sanitized = sanitized.replaceAll('\x00', '');

    // Length validation
    if (sanitized.length < AppConstants.minPasswordLength) {
      throw ArgumentError(AppConstants.passwordMinLengthMessage);
    }

    if (sanitized.length > AppConstants.maxPasswordLength) {
      throw ArgumentError(AppConstants.passwordMaxLengthMessage);
    }

    // Pattern validation
    if (!AppConstants.passwordRegex.hasMatch(sanitized)) {
      throw ArgumentError(AppConstants.passwordHint);
    }

    return sanitized;
  }

  /// Sanitize phone number
  static String sanitizePhoneNumber(String phone) {
    if (phone.isEmpty) return phone;

    var sanitized = phone.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);

    // Remove all non-numeric characters except +
    sanitized = sanitized.replaceAll(RegExp(r'[^0-9+]'), '');

    // Validate
    if (!AppConstants.phoneRegex.hasMatch(sanitized)) {
      throw ArgumentError('Invalid phone number format');
    }

    return sanitized;
  }

  /// Sanitize URL
  static String sanitizeUrl(String url) {
    if (url.isEmpty) return url;

    var sanitized = url.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);

    // Basic URL validation
    final uri = Uri.tryParse(sanitized);
    if (uri == null || !uri.isAbsolute) {
      throw ArgumentError('Invalid URL format');
    }

    // Whitelist protocols
    if (!['http', 'https'].contains(uri.scheme)) {
      throw ArgumentError('URL must use HTTP or HTTPS protocol');
    }

    return sanitized;
  }

  /// Sanitize general text input
  static String sanitizeText(
    String text, {
    int maxLength = 1000,
    bool allowNewlines = false,
  }) {
    if (text.isEmpty) return text;

    var sanitized = text.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    sanitized = stripEventHandlers(sanitized);

    // Length limit
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    // Optionally remove newlines
    if (!allowNewlines) {
      sanitized = sanitized.replaceAll('\n', ' ');
      sanitized = sanitized.replaceAll('\r', ' ');
    }

    return sanitized;
  }

  /// Sanitize bio text
  static String sanitizeBio(String bio, {int maxLength = AppConstants.maxBioLength}) {
    return sanitizeText(
      bio,
      maxLength: maxLength,
      allowNewlines: true,
    );
  }

  /// Sanitize search query
  static String sanitizeSearchQuery(String query, {int maxLength = 100}) {
    if (query.isEmpty) return query;

    var sanitized = query.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    sanitized = stripEventHandlers(sanitized);

    // Remove special characters that could affect search
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\s\-]'), '');

    // Length limit
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Sanitize UUID
  static String sanitizeUuid(String uuid) {
    if (uuid.isEmpty) return uuid;

    var sanitized = uuid.trim().toLowerCase();
    sanitized = stripControlCharacters(sanitized);

    // UUID format validation
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    );

    if (!uuidRegex.hasMatch(sanitized)) {
      throw ArgumentError('Invalid UUID format');
    }

    return sanitized;
  }

  /// Sanitize ID (alphanumeric and hyphens only)
  static String sanitizeId(String id) {
    if (id.isEmpty) return id;

    var sanitized = id.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\-]'), '');

    if (sanitized.isEmpty) {
      throw ArgumentError('Invalid ID format');
    }

    return sanitized;
  }

  /// Validate and sanitize invite code
  static String sanitizeInviteCode(String code) {
    if (code.isEmpty) return code;

    var sanitized = code.trim().toUpperCase();
    sanitized = stripControlCharacters(sanitized);
    sanitized = sanitized.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (sanitized.length < 6) {
      throw ArgumentError('Invite code must be at least 6 characters');
    }

    return sanitized;
  }

  /// Sanitize file name
  static String sanitizeFileName(String fileName) {
    if (fileName.isEmpty) return fileName;

    var sanitized = fileName.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);

    // Remove path traversal characters
    sanitized = sanitized.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    // Limit length
    const maxFileNameLength = 255;
    if (sanitized.length > maxFileNameLength) {
      final extension = sanitized.contains('.')
          ? sanitized.substring(sanitized.lastIndexOf('.'))
          : '';
      sanitized =
          '${sanitized.substring(0, maxFileNameLength - extension.length)}$extension';
    }

    return sanitized;
  }

  /// Sanitize SQL string (basic escaping)
  ///
  /// Note: This is a last resort. Always use parameterized queries
  /// or ORM methods instead of string concatenation for SQL.
  static String escapeSql(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAll("'", "''")
        .replaceAll('\\', '\\\\')
        .replaceAll('\x00', '')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }

  /// Sanitize JSON string key
  static String sanitizeJsonKey(String key) {
    if (key.isEmpty) return key;

    var sanitized = key.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);

    // Remove characters not valid in JSON keys
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\$\_]'), '_');

    // Must not start with a digit
    if (sanitized.isNotEmpty && RegExp(r'^\d').hasMatch(sanitized)) {
      sanitized = '_$sanitized';
    }

    return sanitized;
  }

  /// Validate and sanitize age
  static int sanitizeAge(int age) {
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      throw ArgumentError(
        'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}',
      );
    }
    return age;
  }

  /// Sanitize session title
  static String sanitizeSessionTitle(String title) {
    return sanitizeText(
      title,
      maxLength: 100,
      allowNewlines: false,
    );
  }

  /// Sanitize notes
  static String sanitizeNotes(String notes, {int maxLength = 2000}) {
    return sanitizeText(
      notes,
      maxLength: maxLength,
      allowNewlines: true,
    );
  }

  /// Check if input contains SQL injection patterns
  static bool containsSqlInjection(String input) {
    if (input.isEmpty) return false;

    final sqlPatterns = [
      RegExp(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER)\b)', caseSensitive: false),
      RegExp(r'(\-\-|\/\*|\*\/)'),
      RegExp(r'(\b(OR|AND)\b\s*\d\s*=\s*\d)', caseSensitive: false),
    ];

    return sqlPatterns.any((pattern) => pattern.hasMatch(input));
  }

  /// Check if input contains XSS patterns
  static bool containsXss(String input) {
    if (input.isEmpty) return false;

    final xssPatterns = [
      RegExp(r'<script[^>]*>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r"on\w+\s*=\s*['\"]", caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'expression\(', caseSensitive: false),
    ];

    return xssPatterns.any((pattern) => pattern.hasMatch(input));
  }
}
