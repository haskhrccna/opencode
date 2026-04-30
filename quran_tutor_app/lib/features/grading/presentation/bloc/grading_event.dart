import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

abstract class GradingEvent extends Equatable {
  const GradingEvent();

  @override
  List<Object?> get props => [];
}

class LoadGrades extends GradingEvent {
  const LoadGrades({this.studentId});
  final String? studentId;

  @override
  List<Object?> get props => [studentId];
}

class LoadGradesBySession extends GradingEvent {
  const LoadGradesBySession(this.sessionId);
  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class LoadGradesByTeacher extends GradingEvent {
  const LoadGradesByTeacher(this.teacherId);
  final String teacherId;

  @override
  List<Object?> get props => [teacherId];
}

class GetGrade extends GradingEvent {
  const GetGrade(this.gradeId);
  final String gradeId;

  @override
  List<Object?> get props => [gradeId];
}

class CreateGrade extends GradingEvent {
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
  final String sessionId;
  final String studentId;
  final String teacherId;
  final GradingCategory category;
  final int grade;
  final String? notes;
  final List<String>? surahs;
  final String? verses;
  final int? pagesMemorized;

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
  const UpdateGrade({
    required this.gradeId,
    this.grade,
    this.notes,
    this.surahs,
    this.verses,
    this.pagesMemorized,
  });
  final String gradeId;
  final int? grade;
  final String? notes;
  final List<String>? surahs;
  final String? verses;
  final int? pagesMemorized;

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
  const DeleteGrade(this.gradeId);
  final String gradeId;

  @override
  List<Object?> get props => [gradeId];
}

class LoadStudentProgress extends GradingEvent {
  const LoadStudentProgress(this.studentId);
  final String studentId;

  @override
  List<Object?> get props => [studentId];
}

class LoadProgressTimeline extends GradingEvent {
  const LoadProgressTimeline({
    required this.studentId,
    required this.startDate,
    required this.endDate,
  });
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [studentId, startDate, endDate];
}

class LoadClassProgress extends GradingEvent {
  const LoadClassProgress(this.teacherId);
  final String teacherId;

  @override
  List<Object?> get props => [teacherId];
}

class UploadAudioFeedback extends GradingEvent {
  const UploadAudioFeedback({
    required this.gradeId,
    required this.audioFilePath,
  });
  final String gradeId;
  final String audioFilePath;

  @override
  List<Object?> get props => [gradeId, audioFilePath];
}

class RefreshGrades extends GradingEvent {
  const RefreshGrades();
}
