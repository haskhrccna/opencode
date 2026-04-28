import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/grading/data/datasources/grading_remote_datasource.dart';
import 'package:quran_tutor_app/features/grading/data/models/grade_model.dart';
import 'package:quran_tutor_app/features/grading/domain/entities/progress_grade.dart';
import 'package:quran_tutor_app/features/grading/domain/repositories/grading_repository.dart';

@Singleton(as: GradingRepository)
class GradingRepositoryImpl implements GradingRepository {

  GradingRepositoryImpl(this._remoteDataSource);
  final GradingRemoteDataSource _remoteDataSource;

  @override
  Future<(ProgressGrade?, Failure?)> getGrade(String gradeId) async {
    try {
      final grade = await _remoteDataSource.getGrade(gradeId);
      return (grade?.toEntity(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<ProgressGrade>?, Failure?)> getGradesBySession(String sessionId) async {
    try {
      final grades = await _remoteDataSource.getGradesBySession(sessionId);
      return (grades.map((g) => g.toEntity()).toList(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<ProgressGrade>?, Failure?)> getGradesByStudent(String studentId) async {
    try {
      final grades = await _remoteDataSource.getGradesByStudent(studentId);
      return (grades.map((g) => g.toEntity()).toList(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<ProgressGrade>?, Failure?)> getGradesByTeacher(String teacherId) async {
    try {
      final grades = await _remoteDataSource.getGradesByTeacher(teacherId);
      return (grades.map((g) => g.toEntity()).toList(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<ProgressGrade>?, Failure?)> getLatestGradesByStudent(
    String studentId, {
    int limit = 10,
  }) async {
    try {
      final grades = await _remoteDataSource.getGradesByStudent(studentId);
      final limited = grades.take(limit).toList();
      return (limited.map((g) => g.toEntity()).toList(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(ProgressGrade?, Failure?)> createGrade({
    required String sessionId,
    required String studentId,
    required String teacherId,
    required GradingCategory category,
    required int grade,
    String? notes,
    List<String>? surahs,
    String? verses,
    int? pagesMemorized,
  }) async {
    try {
      final gradeModel = await _remoteDataSource.createGrade(
        sessionId: sessionId,
        studentId: studentId,
        teacherId: teacherId,
        category: category,
        grade: grade,
        notes: notes,
        surahs: surahs,
        verses: verses,
        pagesMemorized: pagesMemorized,
      );
      return (gradeModel.toEntity(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(ProgressGrade?, Failure?)> updateGrade(ProgressGrade grade) async {
    try {
      final gradeModel = GradeModel.fromEntity(grade);
      final updated = await _remoteDataSource.updateGrade(gradeModel);
      return (updated.toEntity(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> deleteGrade(String gradeId) async {
    try {
      await _remoteDataSource.deleteGrade(gradeId);
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<(ProgressGrade?, Failure?)> uploadAudioFeedback({
    required String gradeId,
    required String audioFilePath,
  }) async {
    try {
      await _remoteDataSource.uploadAudioFeedback(gradeId, audioFilePath);
      final grade = await _remoteDataSource.getGrade(gradeId);
      return (grade?.toEntity(), null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> deleteAudioFeedback(String gradeId) async {
    try {
      await _remoteDataSource.deleteAudioFeedback(gradeId);
      return null;
    } catch (e) {
      return ServerFailure(message: e.toString());
    }
  }

  @override
  Future<(ProgressSummary?, Failure?)> getStudentProgressSummary(String studentId) async {
    try {
      final summary = await _remoteDataSource.getStudentProgressSummary(studentId);
      return (summary, null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(ProgressTimeline?, Failure?)> getProgressTimeline({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final timeline = await _remoteDataSource.getProgressTimeline(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
      );
      return (timeline, null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<StudentProgress>?, Failure?)> getClassProgress(String teacherId) async {
    try {
      final progress = await _remoteDataSource.getClassProgress(teacherId);
      return (progress, null);
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ProgressGrade>> get gradesStream {
    return _remoteDataSource.gradesStream().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
