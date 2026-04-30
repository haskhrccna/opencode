import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/grading/domain/entities/progress_grade.dart';
import 'package:quran_tutor_app/features/grading/domain/repositories/grading_repository.dart';
import 'package:quran_tutor_app/features/grading/presentation/bloc/grading_bloc.dart';
import 'package:quran_tutor_app/features/grading/presentation/bloc/grading_event.dart';
import 'package:quran_tutor_app/features/grading/presentation/bloc/grading_state.dart';

class _MockGradingRepository extends Mock implements GradingRepository {}

class _FakeProgressGrade extends Fake implements ProgressGrade {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeProgressGrade());
    registerFallbackValue(GradingCategory.memorization);
  });

  late _MockGradingRepository repo;

  setUp(() {
    repo = _MockGradingRepository();
  });

  final tGrade = ProgressGrade(
    id: 'g-1',
    sessionId: 's-1',
    studentId: 'st-1',
    teacherId: 't-1',
    category: GradingCategory.memorization,
    grade: 5,
    createdAt: DateTime.utc(2026, 4, 29),
  );

  group('LoadGrades', () {
    blocTest<GradingBloc, GradingState>(
      'emits [loading, loaded] on success',
      build: () {
        when(() => repo.getGradesByStudent(any()))
            .thenAnswer((_) async => ([tGrade], null));
        return GradingBloc(repo);
      },
      act: (b) => b.add(const LoadGrades(studentId: 'st-1')),
      expect: () => [
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.loading,
        ),
        isA<GradingState>()
            .having((s) => s.status, 'status', GradingStatus.loaded)
            .having((s) => s.grades, 'grades', [tGrade]),
      ],
    );

    blocTest<GradingBloc, GradingState>(
      'emits [loading, error] when studentId missing',
      build: () => GradingBloc(repo),
      act: (b) => b.add(const LoadGrades()),
      expect: () => [
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.loading,
        ),
        isA<GradingState>()
            .having((s) => s.status, 'status', GradingStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Student ID required',
            ),
      ],
    );

    blocTest<GradingBloc, GradingState>(
      'emits [loading, error] on repository failure',
      build: () {
        when(() => repo.getGradesByStudent(any())).thenAnswer(
          (_) async => (null, ServerFailure.internalError()),
        );
        return GradingBloc(repo);
      },
      act: (b) => b.add(const LoadGrades(studentId: 'st-1')),
      expect: () => [
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.loading,
        ),
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.error,
        ),
      ],
    );
  });

  group('CreateGrade', () {
    blocTest<GradingBloc, GradingState>(
      'emits [creating, loaded] on success',
      build: () {
        when(
          () => repo.createGrade(
            sessionId: any(named: 'sessionId'),
            studentId: any(named: 'studentId'),
            teacherId: any(named: 'teacherId'),
            category: any(named: 'category'),
            grade: any(named: 'grade'),
            notes: any(named: 'notes'),
            surahs: any(named: 'surahs'),
            verses: any(named: 'verses'),
            pagesMemorized: any(named: 'pagesMemorized'),
          ),
        ).thenAnswer((_) async => (tGrade, null));
        return GradingBloc(repo);
      },
      act: (b) => b.add(
        const CreateGrade(
          sessionId: 's-1',
          studentId: 'st-1',
          teacherId: 't-1',
          category: GradingCategory.memorization,
          grade: 5,
        ),
      ),
      expect: () => [
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.creating,
        ),
        isA<GradingState>()
            .having((s) => s.status, 'status', GradingStatus.loaded)
            .having((s) => s.selectedGrade, 'selectedGrade', tGrade),
      ],
    );
  });

  group('DeleteGrade', () {
    blocTest<GradingBloc, GradingState>(
      'emits [deleting, loaded] on success',
      build: () {
        when(() => repo.deleteGrade('g-1')).thenAnswer((_) async => null);
        return GradingBloc(repo);
      },
      act: (b) => b.add(const DeleteGrade('g-1')),
      expect: () => [
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.deleting,
        ),
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.loaded,
        ),
      ],
    );
  });

  group('LoadStudentProgress', () {
    final tSummary = ProgressSummary(
      studentId: 'st-1',
      totalSessions: 10,
      sessionsGraded: 8,
      averageGrade: 4.2,
      categoryAverages: const {},
      currentStreak: 3,
      longestStreak: 5,
      totalPagesMemorized: 12,
      surahsMemorized: const ['Al-Fatiha'],
    );

    blocTest<GradingBloc, GradingState>(
      'emits [loading, loaded with summary] on success',
      build: () {
        when(() => repo.getStudentProgressSummary(any()))
            .thenAnswer((_) async => (tSummary, null));
        return GradingBloc(repo);
      },
      act: (b) => b.add(const LoadStudentProgress('st-1')),
      expect: () => [
        isA<GradingState>().having(
          (s) => s.status,
          'status',
          GradingStatus.loading,
        ),
        isA<GradingState>()
            .having((s) => s.status, 'status', GradingStatus.loaded)
            .having((s) => s.progressSummary, 'progressSummary', tSummary),
      ],
    );
  });
}
