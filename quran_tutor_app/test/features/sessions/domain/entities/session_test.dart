import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';

void main() {
  Session sample({
    DateTime? scheduledAt,
    int durationMinutes = 60,
    SessionStatus status = SessionStatus.scheduled,
  }) {
    return Session(
      id: 's-1',
      teacherId: 't-1',
      scheduledAt:
          scheduledAt ?? DateTime.now().toUtc().add(const Duration(hours: 1)),
      status: status,
      createdAt: DateTime.utc(2026, 4, 29),
      durationMinutes: durationMinutes,
    );
  }

  group('Session.empty', () {
    test('returns valid empty session', () {
      final s = Session.empty();
      expect(s.id, '');
      expect(s.teacherId, '');
      expect(s.status, SessionStatus.scheduled);
    });
  });

  group('isUpcoming / isInProgress / isCompleted / isCancelled', () {
    test('isUpcoming true when scheduled and in future', () {
      expect(sample().isUpcoming, isTrue);
    });

    test('isUpcoming false when scheduled but in past', () {
      final past = DateTime.now().toUtc().subtract(const Duration(hours: 1));
      expect(sample(scheduledAt: past).isUpcoming, isFalse);
    });

    test('isUpcoming false when status is not scheduled', () {
      expect(
        sample(status: SessionStatus.completed).isUpcoming,
        isFalse,
      );
    });

    test('isInProgress / isCompleted / isCancelled', () {
      expect(
        sample(status: SessionStatus.inProgress).isInProgress,
        isTrue,
      );
      expect(
        sample(status: SessionStatus.completed).isCompleted,
        isTrue,
      );
      expect(
        sample(status: SessionStatus.cancelled).isCancelled,
        isTrue,
      );
    });
  });

  group('endAt', () {
    test('adds durationMinutes to scheduledAt', () {
      final start = DateTime.utc(2026, 4, 29, 10);
      final s = sample(scheduledAt: start, durationMinutes: 90);
      expect(s.endAt, DateTime.utc(2026, 4, 29, 11, 30));
    });
  });

  group('isNow', () {
    test('true when current time is between scheduledAt and endAt', () {
      final start =
          DateTime.now().toUtc().subtract(const Duration(minutes: 10));
      expect(
        sample(scheduledAt: start, durationMinutes: 60).isNow,
        isTrue,
      );
    });

    test('false when current time is after endAt', () {
      final start = DateTime.now().toUtc().subtract(const Duration(hours: 5));
      expect(
        sample(scheduledAt: start, durationMinutes: 60).isNow,
        isFalse,
      );
    });
  });

  group('formattedLocalTime', () {
    test('contains year and a colon', () {
      final s = sample(scheduledAt: DateTime.utc(2026, 4, 29, 14, 30));
      expect(s.formattedLocalTime, contains('2026'));
      expect(s.formattedLocalTime.contains(':'), isTrue);
    });
  });

  group('durationText', () {
    test('returns minutes for <60', () {
      expect(sample(durationMinutes: 45).durationText, '45 min');
    });

    test('returns hours for whole hours', () {
      expect(sample(durationMinutes: 120).durationText, '2 hr');
    });

    test('returns hours+min for non-whole', () {
      expect(sample(durationMinutes: 90).durationText, '1 hr 30 min');
    });
  });

  group('copyWith', () {
    test('overrides only specified fields', () {
      final s = sample();
      final updated = s.copyWith(status: SessionStatus.completed);
      expect(updated.status, SessionStatus.completed);
      expect(updated.id, s.id);
      expect(updated.scheduledAt, s.scheduledAt);
    });
  });

  group('Equatable', () {
    test('two equal sessions compare equal', () {
      final start = DateTime.utc(2026, 4, 29, 10);
      expect(
        sample(scheduledAt: start, durationMinutes: 60),
        equals(sample(scheduledAt: start, durationMinutes: 60)),
      );
    });
  });
}
