import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/progress_grade.dart';
import '../../domain/repositories/grading_repository.dart';

abstract class GradingEvent extends Equatable {
  const GradingEvent();

  @override
  List<Object?> get props => [];
}

class LoadGrades extends GradingEvent {
  final String? studentId;

  const LoadGrades({this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class LoadGradesBySession extends GradingEvent {
  final String sessionId;

  const LoadGradesBySession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class LoadGradesByTeacher extends GradingEvent {
  final String teacherId;

  const LoadGradesByTeacher(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class GetGrade extends GradingEvent {
  final String gradeId;

  const GetGrade(this.gradeId);

  @override
  List<Object?> get props => [gradeId];
}

class CreateGrade extends GradingEvent {
  final String sessionId;
  final String studentId;
  final String teacherId;
  final GradingCategory category;
  final int grade;
  final String? notes;
  final List<String>? surahs;
  final String? verses;
  final int? pagesMemorized;

  const CreateGrade({
    required this.sessionId,
    required this.studentId,
    required this.teacherId,
    required this.category,
    required this.grade,
    this.notes,
    this.surahs,
    this.verses,
    this.pagesMemorized,
  });

  @override
  List<Object?> get props => [
        sessionId,
        studentId,
        teacherId,
        category,
        grade,
        notes,
        surahs,
        verses,
        pagesMemorized,
      ];
}

class UpdateGrade extends GradingEvent {
  final String gradeId;
  final int? grade;
  final String? notes;
  final List<String>? surahs;
  final String? verses;
  final int? pagesMemorized;

  const UpdateGrade({
    required this.gradeId,
    this.grade,
    this.notes,
    this.surahs,
    this.verses,
    this.pagesMemorized,
  });

  @override
  List<Object?> get props => [
        gradeId,
        grade,
        notes,
        surahs,
        verses,
        pagesMemorized,
      ];
}

class DeleteGrade extends GradingEvent {
  final String gradeId;

  const DeleteGrade(this.gradeId);

  @override
  List<Object?> get props => [gradeId];
}

class LoadStudentProgress extends GradingEvent {
  final String studentId;

  const LoadStudentProgress(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadProgressTimeline extends GradingEvent {
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadProgressTimeline({
    required this.studentId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [studentId, startDate, endDate];
}

class LoadClassProgress extends GradingEvent {
  final String teacherId;

  const LoadClassProgress(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class UploadAudioFeedback extends GradingEvent {
  final String gradeId;
  final String audioFilePath;

  const UploadAudioFeedback({
    required this.gradeId,
    required this.audioFilePath,
  });

  @override
  List<Object?> get props => [gradeId, audioFilePath];
}

class RefreshGrades extends GradingEvent {
  const RefreshGrades();
}
