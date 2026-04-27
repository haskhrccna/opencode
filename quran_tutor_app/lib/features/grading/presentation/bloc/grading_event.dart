import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/repositories/grading_repository.dart';

part 'grading_event.freezed.dart';

@freezed
class GradingEvent with _$GradingEvent {
  const factory GradingEvent.loadGrades({String? studentId}) = LoadGrades;

  const factory GradingEvent.loadGradesBySession(String sessionId) = LoadGradesBySession;

  const factory GradingEvent.loadGradesByTeacher(String teacherId) = LoadGradesByTeacher;

  const factory GradingEvent.getGrade(String gradeId) = GetGrade;

  const factory GradingEvent.createGrade({
    required String sessionId,
    required String studentId,
    required String teacherId,
    required GradingCategory category,
    required int grade,
    String? notes,
    List<String>? surahs,
    String? verses,
    int? pagesMemorized,
  }) = CreateGrade;

  const factory GradingEvent.updateGrade({
    required String gradeId,
    int? grade,
    String? notes,
    List<String>? surahs,
    String? verses,
    int? pagesMemorized,
  }) = UpdateGrade;

  const factory GradingEvent.deleteGrade(String gradeId) = DeleteGrade;

  const factory GradingEvent.loadStudentProgress(String studentId) = LoadStudentProgress;

  const factory GradingEvent.loadProgressTimeline({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) = LoadProgressTimeline;

  const factory GradingEvent.loadClassProgress(String teacherId) = LoadClassProgress;

  const factory GradingEvent.uploadAudioFeedback({
    required String gradeId,
    required String audioFilePath,
  }) = UploadAudioFeedback;

  const factory GradingEvent.refreshGrades() = RefreshGrades;
}
