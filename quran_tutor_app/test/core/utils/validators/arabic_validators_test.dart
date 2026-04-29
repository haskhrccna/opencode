import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/utils/validators/arabic_validators.dart';

void main() {
  group('validateArabicName', () {
    test('returns null for a valid Arabic name', () {
      expect(ArabicValidators.validateArabicName('حسن آدم'), isNull);
    });

    test('rejects empty', () {
      expect(
        ArabicValidators.validateArabicName(''),
        'validation.name_arabic_required',
      );
    });

    test('rejects English characters', () {
      expect(
        ArabicValidators.validateArabicName('Hassan'),
        'validation.name_arabic_invalid',
      );
    });

    test('rejects too short', () {
      expect(
        ArabicValidators.validateArabicName('ا'),
        'validation.name_arabic_min_length',
      );
    });

    test('rejects consecutive spaces', () {
      expect(
        ArabicValidators.validateArabicName('حسن  آدم'),
        'validation.name_consecutive_spaces',
      );
    });
  });

  group('validateEnglishName', () {
    test('returns null for valid name', () {
      expect(ArabicValidators.validateEnglishName('Hassan Adam'), isNull);
    });

    test('rejects digits in name', () {
      expect(
        ArabicValidators.validateEnglishName('Hassan1'),
        'validation.name_english_invalid',
      );
    });
  });

  group('validateEmail', () {
    test('returns null for a valid email', () {
      expect(ArabicValidators.validateEmail('a@b.co'), isNull);
    });

    test('rejects empty', () {
      expect(ArabicValidators.validateEmail(''), 'validation.required');
    });

    test('rejects malformed email', () {
      expect(
        ArabicValidators.validateEmail('not-email'),
        'validation.email_invalid',
      );
    });
  });

  group('validatePhone (international)', () {
    test('returns null for +966 (Saudi)', () {
      expect(ArabicValidators.validatePhone('+966501234567'), isNull);
    });

    test('returns null for +1 (US)', () {
      expect(ArabicValidators.validatePhone('+14155552671'), isNull);
    });

    test('returns null for +44 (UK) with spaces and dashes', () {
      expect(ArabicValidators.validatePhone('+44 20 7946-0958'), isNull);
    });

    test('returns null for +20 (Egypt) with parentheses', () {
      expect(ArabicValidators.validatePhone('+20 (10) 1234 5678'), isNull);
    });

    test('returns null for digits without leading + (10-digit local)', () {
      expect(ArabicValidators.validatePhone('1234567890'), isNull);
    });

    test('rejects empty', () {
      expect(
        ArabicValidators.validatePhone(''),
        'validation.phone_required',
      );
    });

    test('rejects too-short numbers (<7 digits)', () {
      expect(
        ArabicValidators.validatePhone('+1234'),
        'validation.phone_invalid',
      );
    });

    test('rejects numbers starting with 0 after the +', () {
      expect(
        ArabicValidators.validatePhone('+0123456789'),
        'validation.phone_invalid',
      );
    });

    test('rejects non-digit characters (letters)', () {
      expect(
        ArabicValidators.validatePhone('+1-abc-defg-hij'),
        'validation.phone_invalid',
      );
    });
  });

  group('validatePassword', () {
    test('returns null for a strong password', () {
      expect(ArabicValidators.validatePassword('Aa1bcdef'), isNull);
    });

    test('rejects too short', () {
      expect(
        ArabicValidators.validatePassword('Aa1'),
        'validation.password_min_length',
      );
    });

    test('rejects missing uppercase', () {
      expect(
        ArabicValidators.validatePassword('aa1bcdef'),
        'validation.password_uppercase',
      );
    });

    test('rejects missing lowercase', () {
      expect(
        ArabicValidators.validatePassword('AA1BCDEF'),
        'validation.password_lowercase',
      );
    });

    test('rejects missing digit', () {
      expect(
        ArabicValidators.validatePassword('Aabcdefg'),
        'validation.password_number',
      );
    });
  });

  group('validatePasswordConfirmation', () {
    test('returns null when matches', () {
      expect(
        ArabicValidators.validatePasswordConfirmation('abc', 'abc'),
        isNull,
      );
    });

    test('reports mismatch', () {
      expect(
        ArabicValidators.validatePasswordConfirmation('abc', 'xyz'),
        'validation.password_mismatch',
      );
    });
  });

  group('validateAge', () {
    test('accepts within range', () {
      expect(ArabicValidators.validateAge('20'), isNull);
    });

    test('rejects below minimum', () {
      expect(ArabicValidators.validateAge('2'), 'validation.age_min');
    });

    test('rejects above maximum', () {
      expect(ArabicValidators.validateAge('200'), 'validation.age_max');
    });

    test('rejects non-numeric', () {
      expect(ArabicValidators.validateAge('abc'), 'validation.age_invalid');
    });
  });

  group('validateInviteCode', () {
    test('accepts 6+ alphanumeric', () {
      expect(ArabicValidators.validateInviteCode('ABC123'), isNull);
    });

    test('rejects too short', () {
      expect(
        ArabicValidators.validateInviteCode('AB12'),
        'validation.invite_code_min_length',
      );
    });

    test('rejects non-alphanumeric chars', () {
      expect(
        ArabicValidators.validateInviteCode('ABC-123'),
        'validation.invite_code_invalid',
      );
    });
  });

  group('validateUrl', () {
    test('accepts https URL', () {
      expect(ArabicValidators.validateUrl('https://example.com'), isNull);
    });

    test('accepts http URL', () {
      expect(ArabicValidators.validateUrl('http://example.com'), isNull);
    });

    test('returns null for empty (URL is optional)', () {
      expect(ArabicValidators.validateUrl(''), isNull);
    });

    test('rejects malformed URL', () {
      expect(
        ArabicValidators.validateUrl('not a url'),
        'validation.url_invalid',
      );
    });
  });

  group('StringValidation extension', () {
    test('isNullOrEmpty handles whitespace', () {
      const String? s = '   ';
      expect(s.isNullOrEmpty, isTrue);
      expect(s.isNotNullOrEmpty, isFalse);
    });

    test('isValidEmail / isValidPhone work', () {
      expect('foo@bar.co'.isValidEmail, isTrue);
      expect('+966501234567'.isValidPhone, isTrue);
      expect('not-email'.isValidEmail, isFalse);
    });
  });
}
