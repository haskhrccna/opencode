import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/grading/data/datasources/grading_remote_datasource.dart';
import 'package:quran_tutor_app/features/grading/data/models/grade_model.dart';
import 'package:quran_tutor_app/features/grading/data/repositories/grading_repository_impl.dart';
import 'package:quran_tutor_app/features/grading/domain/entities/progress_grade.dart';

class _MockGradingRemoteDataSource extends Mock
    implements GradingRemoteDataSource {}

class _FakeGradeModel extends Fake implements GradeModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeGradeModel());
    registerFallbackValue(GradingCategory.memorization);
  });

  late _MockGradingRemoteDataSource ds;
  late GradingRepositoryImpl repo;

  setUp(() {
    ds = _MockGradingRemoteDataSource();
    repo = GradingRepositoryImpl(ds);
  });

  final tCreatedAt = DateTime.utc(2026, 4, 29);

  GradeModel makeModel({String id = 'g-1', int grade = 5}) => GradeModel(
        id: id,
        sessionId: 's-1',
        studentId: 'st-1',
        teacherId: 't-1',
        category: 'memorization',
        grade: grade,
        createdAt: tCreatedAt,
      );

  group('getGrade', () {
    test('returns entity on success', () async {
      when(() => ds.getGrade('g-1')).thenAnswer((_) async => makeModel());

      final (grade, failure) = await repo.getGrade('g-1');
      expect(failure, isNull);
      expect(grade, isNotNull);
      expect(grade!.id, 'g-1');
      expect(grade.category, GradingCategory.memorization);
    });

    test('returns ServerFailure on ServerException', () async {
      when(() => ds.getGrade(any())).thenThrow(
        const ServerException(message: 'boom'),
      );

      final (grade, failure) = await repo.getGrade('g-1');
      expect(grade, isNull);
      expect(failure, isA<ServerFailure>());
    });

    test('returns UnknownFailure on generic exception', () async {
      when(() => ds.getGrade(any())).thenThrow(Exception('boom'));

      final (grade, failure) = await repo.getGrade('g-1');
      expect(grade, isNull);
      expect(failure, isA<UnknownFailure>());
    });
  });

  group('getGradesByStudent', () {
    test('maps list of models to entities', () async {
      when(() => ds.getGradesByStudent('st-1')).thenAnswer(
        (_) async => [makeModel(id: 'g-1'), makeModel(id: 'g-2', grade: 3)],
      );

      final (grades, failure) = await repo.getGradesByStudent('st-1');
      expect(failure, isNull);
      expect(grades, isNotNull);
      expect(grades!.length, 2);
      expect(grades.first.id, 'g-1');
      expect(grades.last.grade, 3);
    });
  });

  group('getLatestGradesByStudent', () {
    test('respects the limit', () async {
      when(() => ds.getGradesByStudent('st-1')).thenAnswer(
        (_) async => [
          makeModel(id: 'a'),
          makeModel(id: 'b'),
          makeModel(id: 'c'),
        ],
      );

      final (grades, _) = await repo.getLatestGradesByStudent('st-1', limit: 2);
      expect(grades!.length, 2);
      expect(grades.first.id, 'a');
    });
  });

  group('createGrade', () {
    test('returns created entity', () async {
      when(
        () => ds.createGrade(
          sessionId: 's-1',
          studentId: 'st-1',
          teacherId: 't-1',
          category: GradingCategory.memorization,
          grade: 5,
        ),
      ).thenAnswer((_) async => makeModel());

      final (grade, failure) = await repo.createGrade(
        sessionId: 's-1',
        studentId: 'st-1',
        teacherId: 't-1',
        category: GradingCategory.memorization,
        grade: 5,
      );

      expect(failure, isNull);
      expect(grade!.id, 'g-1');
      expect(grade.grade, 5);
    });
  });

  group('updateGrade', () {
    test('round-trips entity through GradeModel', () async {
      when(() => ds.updateGrade(any<GradeModel>()))
          .thenAnswer((_) async => makeModel());
      final entity = ProgressGrade(
        id: 'g-1',
        sessionId: 's-1',
        studentId: 'st-1',
        teacherId: 't-1',
        category: GradingCategory.tajweed,
        grade: 4,
        createdAt: tCreatedAt,
      );

      final (updated, failure) = await repo.updateGrade(entity);
      expect(failure, isNull);
      expect(updated, isNotNull);
    });
  });

  group('deleteGrade', () {
    test('returns null on success', () async {
      when(() => ds.deleteGrade('g-1')).thenAnswer((_) async {});

      final failure = await repo.deleteGrade('g-1');
      expect(failure, isNull);
    });

    test('returns ServerFailure on ServerException', () async {
      when(() => ds.deleteGrade(any())).thenThrow(
        const ServerException(message: 'nope'),
      );

      final failure = await repo.deleteGrade('g-1');
      expect(failure, isA<ServerFailure>());
    });

    test('returns UnknownFailure on generic exception', () async {
      when(() => ds.deleteGrade(any())).thenThrow(Exception('nope'));

      final failure = await repo.deleteGrade('g-1');
      expect(failure, isA<UnknownFailure>());
    });
  });
}
