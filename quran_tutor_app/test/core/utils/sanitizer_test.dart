import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/utils/sanitizer.dart';

void main() {
  group('Sanitizer.stripControlCharacters', () {
    test('removes ASCII control characters', () {
      expect(Sanitizer.stripControlCharacters('abc'), 'abc');
    });

    test('keeps tabs and newlines (only strips dangerous controls)', () {
      // The regex preserves \t (0x09), \n (0x0A), \r (0x0D).
      expect(Sanitizer.stripControlCharacters('a\tb\nc'), 'a\tb\nc');
    });

    test('returns empty for empty input', () {
      expect(Sanitizer.stripControlCharacters(''), '');
    });
  });

  group('Sanitizer.stripHtmlTags', () {
    test('removes simple tags', () {
      expect(Sanitizer.stripHtmlTags('<b>hi</b>'), 'hi');
    });

    test('removes nested tags', () {
      expect(Sanitizer.stripHtmlTags('<div><span>x</span></div>'), 'x');
    });
  });

  group('Sanitizer.sanitizeEmail', () {
    test('lowercases and trims', () {
      expect(Sanitizer.sanitizeEmail('  Foo@Bar.COM '), 'foo@bar.com');
    });

    test('throws on invalid email', () {
      expect(
        () => Sanitizer.sanitizeEmail('not-an-email'),
        throwsArgumentError,
      );
    });
  });

  group('Sanitizer.sanitizePassword', () {
    test('accepts a strong password', () {
      expect(Sanitizer.sanitizePassword('Aa1bcdef'), 'Aa1bcdef');
    });

    test('rejects too-short password', () {
      expect(() => Sanitizer.sanitizePassword('Aa1'), throwsArgumentError);
    });

    test('rejects password without digit', () {
      expect(
        () => Sanitizer.sanitizePassword('AbcdefghIJ'),
        throwsArgumentError,
      );
    });

    test('strips null bytes before validating', () {
      expect(Sanitizer.sanitizePassword('Aa1bcd\x00ef'), 'Aa1bcdef');
    });
  });

  group('Sanitizer.sanitizePhoneNumber', () {
    test('strips formatting and accepts +966', () {
      expect(
        Sanitizer.sanitizePhoneNumber('+966 5 0 123 4567'),
        '+966501234567',
      );
    });

    test('accepts an international +1 number', () {
      expect(
        Sanitizer.sanitizePhoneNumber('+1 (415) 555-2671'),
        '+14155552671',
      );
    });

    test('rejects clearly invalid (too short) numbers', () {
      expect(
        () => Sanitizer.sanitizePhoneNumber('+12'),
        throwsArgumentError,
      );
    });
  });

  group('Sanitizer.sanitizeUrl', () {
    test('accepts https URL', () {
      expect(
        Sanitizer.sanitizeUrl('https://example.com/path'),
        'https://example.com/path',
      );
    });

    test('rejects javascript: scheme', () {
      expect(
        () => Sanitizer.sanitizeUrl('javascript:alert(1)'),
        throwsArgumentError,
      );
    });

    test('rejects relative URL', () {
      expect(() => Sanitizer.sanitizeUrl('foo/bar'), throwsArgumentError);
    });
  });

  group('Sanitizer.sanitizeUuid', () {
    test('accepts canonical UUID', () {
      expect(
        Sanitizer.sanitizeUuid('20D7F2A7-3E0A-42EF-8CE1-6BE84BB46EBA'),
        '20d7f2a7-3e0a-42ef-8ce1-6be84bb46eba',
      );
    });

    test('rejects malformed UUID', () {
      expect(() => Sanitizer.sanitizeUuid('not-a-uuid'), throwsArgumentError);
    });
  });

  group('Sanitizer.sanitizeInviteCode', () {
    test('uppercases, strips non-alphanumeric, accepts >=6', () {
      expect(Sanitizer.sanitizeInviteCode('abc-123x'), 'ABC123X');
    });

    test('rejects too-short codes', () {
      expect(
        () => Sanitizer.sanitizeInviteCode('a-b'),
        throwsArgumentError,
      );
    });
  });

  group('Sanitizer.sanitizeFileName', () {
    test('replaces path traversal characters', () {
      expect(
        Sanitizer.sanitizeFileName('../etc/passwd'),
        '.._etc_passwd',
      );
    });

    test('keeps the extension when truncating long names', () {
      final longName = '${'a' * 300}.txt';
      final out = Sanitizer.sanitizeFileName(longName);
      expect(out.endsWith('.txt'), isTrue);
      expect(out.length <= 255, isTrue);
    });
  });

  group('Sanitizer.escapeSql', () {
    test('escapes single quotes by doubling', () {
      expect(Sanitizer.escapeSql("O'Brien"), "O''Brien");
    });
  });

  group('Sanitizer.containsSqlInjection', () {
    test('detects classic OR 1=1 payload', () {
      expect(
        Sanitizer.containsSqlInjection("' OR 1=1 --"),
        isTrue,
      );
    });

    test('does not flag normal text', () {
      expect(Sanitizer.containsSqlInjection('hello world'), isFalse);
    });
  });

  group('Sanitizer.containsXss', () {
    test('detects script tag', () {
      expect(Sanitizer.containsXss('<script>alert(1)</script>'), isTrue);
    });

    test('detects javascript: scheme', () {
      expect(Sanitizer.containsXss('javascript:alert(1)'), isTrue);
    });

    test('does not flag normal text', () {
      expect(Sanitizer.containsXss('hello world'), isFalse);
    });
  });

  group('Sanitizer.sanitizeAge', () {
    test('passes valid ages through', () {
      expect(Sanitizer.sanitizeAge(25), 25);
    });

    test('rejects ages out of range', () {
      expect(() => Sanitizer.sanitizeAge(2), throwsArgumentError);
      expect(() => Sanitizer.sanitizeAge(200), throwsArgumentError);
    });
  });
}
