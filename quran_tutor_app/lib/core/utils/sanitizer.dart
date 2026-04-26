import 'package:flutter/foundation.dart';

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
    return input.replaceAll(
      RegExp(r'\s(on\w+\s*=\s*["\'][^"\']*["\'])', caseSensitive: false),
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
      throw ArgumentError(
        'Password must be at least ${AppConstants.minPasswordLength} characters',
      );
    }
    
    if (sanitized.length > AppConstants.maxPasswordLength) {
      throw ArgumentError(
        'Password must not exceed ${AppConstants.maxPasswordLength} characters',
      );
    }
    
    return sanitized;
  }

  /// Sanitize phone number (E.164 format)
  static String sanitizePhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    
    // Remove all non-digit characters except + at start
    var sanitized = phone.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    
    // Keep only digits and leading +
    final hasPlus = sanitized.startsWith('+');
    sanitized = sanitized.replaceAll(RegExp(r'[^\d]'), '');
    if (hasPlus) {
      sanitized = '+$sanitized';
    }
    
    // Validate length (E.164 requires 7-15 digits)
    final digitCount = sanitized.replaceAll('+', '').length;
    if (digitCount < 7 || digitCount > 15) {
      throw ArgumentError('Invalid phone number length');
    }
    
    return sanitized;
  }

  /// Sanitize URL
  static String sanitizeUrl(String url) {
    if (url.isEmpty) return url;
    
    var sanitized = url.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    
    // Validate URL format
    final urlPattern = RegExp(
      r'^(http|https)://[\w\-\.]+\.[\w]{2,}(/\S*)?$',
      caseSensitive: false,
    );
    
    if (!urlPattern.hasMatch(sanitized)) {
      throw ArgumentError('Invalid URL format');
    }
    
    return sanitized;
  }

  /// Sanitize bio/text with max length
  static String sanitizeBio(
    String bio, {
    int maxLength = AppConstants.maxBioLength,
  }) {
    if (bio.isEmpty) return bio;
    
    var sanitized = bio.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    sanitized = stripEventHandlers(sanitized);
    
    // Length limit
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }

  /// Validate enum value against allow-list
  static T validateEnum<T>(
    String value,
    List<T> allowedValues, {
    required T defaultValue,
  }) {
    try {
      final sanitized = stripControlCharacters(value.trim());
      
      for (final allowed in allowedValues) {
        if (allowed.toString().toLowerCase() == sanitized.toLowerCase()) {
          return allowed;
        }
      }
      
      return defaultValue;
    } catch (e) {
      if (kDebugMode) {
        print('Enum validation error: $e');
      }
      return defaultValue;
    }
  }

  /// Sanitize generic text
  static String sanitizeText(
    String text, {
    int maxLength = 1000,
    bool allowNewlines = true,
  }) {
    if (text.isEmpty) return text;
    
    var sanitized = text.trim();
    sanitized = stripControlCharacters(sanitized);
    sanitized = stripHtmlTags(sanitized);
    sanitized = stripEventHandlers(sanitized);
    
    // Optionally remove newlines
    if (!allowNewlines) {
      sanitized = sanitized.replaceAll('\n', ' ');
      sanitized = sanitized.replaceAll('\r', '');
    }
    
    // Collapse multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    // Length limit
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }

  /// Sanitize invite code (alphanumeric only)
  static String sanitizeInviteCode(String code) {
    if (code.isEmpty) return code;
    
    var sanitized = code.trim().toUpperCase();
    sanitized = sanitized.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    return sanitized;
  }
}

/// Extension methods for String sanitization
extension StringSanitizer on String {
  /// Sanitize as name
  String sanitizedName({int maxLength = 50}) =>
      Sanitizer.sanitizeName(this, maxLength: maxLength);

  /// Sanitize as email
  String get sanitizedEmail => Sanitizer.sanitizeEmail(this);

  /// Sanitize as phone
  String get sanitizedPhone => Sanitizer.sanitizePhoneNumber(this);

  /// Sanitize as bio
  String sanitizedBio({int maxLength = 500}) =>
      Sanitizer.sanitizeBio(this, maxLength: maxLength);

  /// Sanitize as generic text
  String sanitizedText({int maxLength = 1000}) =>
      Sanitizer.sanitizeText(this, maxLength: maxLength);

  /// Strip control characters
  String get withoutControlChars => Sanitizer.stripControlCharacters(this);

  /// Strip HTML tags
  String get withoutHtmlTags => Sanitizer.stripHtmlTags(this);
}
