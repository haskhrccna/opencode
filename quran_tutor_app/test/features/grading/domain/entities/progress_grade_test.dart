import 'package:flutter_test/flutter_test.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/grading/domain/entities/progress_grade.dart';

void main() {
  ProgressGrade sample({int grade = 5, String? audioUrl}) => ProgressGrade(
        id: 'g-1',
        sessionId: 's-1',
        studentId: 'st-1',
        teacherId: 't-1',
        category: GradingCategory.memorization,
        grade: grade,
        createdAt: DateTime.utc(2026, 4, 29),
        audioFeedbackUrl: audioUrl,
      );

  group('ProgressGrade.empty', () {
    test('creates a default grade=1 memorization entry', () {
      final empty = ProgressGrade.empty();
      expect(empty.grade, 1);
      expect(empty.category, GradingCategory.memorization);
      expect(empty.id, '');
    });
  });

  group('hasAudioFeedback', () {
    test('false when audioFeedbackUrl is null', () {
      expect(sample().hasAudioFeedback, isFalse);
    });

    test('false when audioFeedbackUrl is empty', () {
      expect(sample(audioUrl: '').hasAudioFeedback, isFalse);
    });

    test('true when audioFeedbackUrl is non-empty', () {
      expect(sample(audioUrl: 'https://x/a.mp3').hasAudioFeedback, isTrue);
    });
  });

  group('gradePercentage', () {
    test('5 -> 100', () => expect(sample(grade: 5).gradePercentage, 100));
    test('3 -> 60', () => expect(sample(grade: 3).gradePercentage, 60));
    test('1 -> 20', () => expect(sample(grade: 1).gradePercentage, 20));
  });

  group('gradeLabel / gradeLabelAr', () {
    test('5 -> Excellent / ممتاز', () {
      expect(sample(grade: 5).gradeLabel, 'Excellent');
      expect(sample(grade: 5).gradeLabelAr, 'ممتاز');
    });

    test('1 -> Poor / ضعيف', () {
      expect(sample(grade: 1).gradeLabel, 'Poor');
      expect(sample(grade: 1).gradeLabelAr, 'ضعيف');
    });

    test('out-of-range -> Not Graded', () {
      expect(sample(grade: 99).gradeLabel, 'Not Graded');
      expect(sample(grade: 0).gradeLabelAr, 'غير مقيم');
    });
  });

  group('gradeColor', () {
    test('5 -> green hex', () {
      expect(sample(grade: 5).gradeColor, 0xFF4CAF50);
    });

    test('1 -> red hex', () {
      expect(sample(grade: 1).gradeColor, 0xFFF44336);
    });
  });

  group('copyWith', () {
    test('overrides only specified fields', () {
      final g = sample();
      final updated = g.copyWith(grade: 4, notes: 'better next time');
      expect(updated.grade, 4);
      expect(updated.notes, 'better next time');
      expect(updated.id, g.id);
      expect(updated.category, g.category);
    });
  });

  group('Equatable', () {
    test('equal grades compare equal', () {
      expect(sample(), equals(sample()));
    });
  });
}
