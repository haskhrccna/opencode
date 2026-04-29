import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/utils/extensions/date_extensions.dart';

void main() {
  group('DateTimeExtensions.isToday/isTomorrow/isYesterday', () {
    test('isToday returns true for now', () {
      expect(DateTime.now().isToday, isTrue);
    });

    test('isTomorrow returns true for now+1d', () {
      expect(DateTime.now().add(const Duration(days: 1)).isTomorrow, isTrue);
    });

    test('isYesterday returns true for now-1d', () {
      expect(
        DateTime.now().subtract(const Duration(days: 1)).isYesterday,
        isTrue,
      );
    });
  });

  group('DateTimeExtensions.startOfDay/endOfDay', () {
    test('startOfDay zeroes time component', () {
      final dt = DateTime(2026, 4, 29, 14, 30, 12);
      expect(dt.startOfDay, DateTime(2026, 4, 29));
    });

    test('endOfDay is one microsecond before next day', () {
      final dt = DateTime(2026, 4, 29, 14, 30, 12);
      final nextDay = DateTime(2026, 4, 30);
      expect(
        nextDay.difference(dt.endOfDay),
        const Duration(microseconds: 1),
      );
    });
  });

  group('DateTimeExtensions.startOfMonth/endOfMonth', () {
    test('startOfMonth is first day at midnight', () {
      final dt = DateTime(2026, 4, 15, 14, 30);
      expect(dt.startOfMonth, DateTime(2026, 4));
    });

    test('endOfMonth handles December rollover', () {
      final dec = DateTime(2026, 12, 15);
      final end = dec.endOfMonth;
      expect(end.year, 2026);
      expect(end.month, 12);
      expect(end.day, 31);
    });
  });

  group('DateTimeExtensions.addDays/subtractDays/differenceInDays', () {
    test('addDays returns expected date', () {
      expect(DateTime(2026, 4, 29).addDays(3), DateTime(2026, 5, 2));
    });

    test('subtractDays returns expected date', () {
      expect(DateTime(2026, 4, 29).subtractDays(3), DateTime(2026, 4, 26));
    });

    test('differenceInDays returns whole days', () {
      final a = DateTime(2026, 4, 29);
      final b = DateTime(2026, 4, 25);
      expect(a.differenceInDays(b), 4);
    });
  });

  group('DateTimeExtensions.isSameDay', () {
    test('same calendar day returns true regardless of time', () {
      expect(
        DateTime(2026, 4, 29, 1).isSameDay(DateTime(2026, 4, 29, 23, 59)),
        isTrue,
      );
    });

    test('different days return false', () {
      expect(
        DateTime(2026, 4, 29).isSameDay(DateTime(2026, 4, 30)),
        isFalse,
      );
    });
  });

  group('DateTimeExtensions.age', () {
    test('returns full years', () {
      final birth = DateTime.now().subtract(const Duration(days: 365 * 25));
      expect(birth.age, anyOf(24, 25));
    });
  });

  group('DateTimeExtensions.arabicDayName', () {
    test('returns a non-empty Arabic day name', () {
      expect(DateTime(2026, 4, 29).arabicDayName.isNotEmpty, isTrue);
    });
  });

  group('DateTimeExtensions.arabicMonthName', () {
    test('matches Gregorian month index', () {
      expect(DateTime(2026).arabicMonthName, 'يناير');
      expect(DateTime(2026, 12).arabicMonthName, 'ديسمبر');
    });
  });

  group('DateTimeExtensions.toRelativeTime', () {
    test('seconds bucket', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 5));
      expect(dt.toRelativeTime(), 'منذ لحظات');
    });

    test('minutes bucket', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      expect(dt.toRelativeTime(), contains('دقيقة'));
    });

    test('hours bucket', () {
      final dt = DateTime.now().subtract(const Duration(hours: 5));
      expect(dt.toRelativeTime(), contains('ساعة'));
    });
  });

  group('DurationExtensions.toShortString', () {
    test('formats hours and minutes with zero-pad', () {
      expect(const Duration(hours: 2, minutes: 5).toShortString(), '02:05');
    });
  });

  group('DurationExtensions.toArabicString', () {
    test('contains hour and minute parts', () {
      final out = const Duration(hours: 1, minutes: 30).toArabicString();
      expect(out, contains('ساعة'));
      expect(out, contains('دقيقة'));
    });
  });
}
