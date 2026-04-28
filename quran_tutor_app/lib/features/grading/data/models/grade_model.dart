import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/grading/domain/entities/progress_grade.dart';

/// Data model for grades
class GradeModel {

  GradeModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.teacherId,
    required this.category,
    required this.grade,
    required this.createdAt, this.notes,
    this.audioFeedbackUrl,
    this.updatedAt,
    this.surahs,
    this.verses,
    this.pagesMemorized,
    this.metadata,
  });

  factory GradeModel.fromSupabase(Map<String, dynamic> data) {
    return GradeModel(
      id: (data['id'] as String?) ?? '',
      sessionId: (data['session_id'] as String?) ?? '',
      studentId: (data['student_id'] as String?) ?? '',
      teacherId: (data['teacher_id'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'memorization',
      grade: (data['grade'] as num?)?.toInt() ?? 1,
      notes: data['notes'] as String?,
      audioFeedbackUrl: data['audio_feedback_url'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      surahs: data['surahs'] != null
          ? List<String>.from(data['surahs'] as List)
          : null,
      verses: data['verses'] as String?,
      pagesMemorized: (data['pages_memorized'] as num?)?.toInt(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  factory GradeModel.fromEntity(ProgressGrade entity) {
    return GradeModel(
      id: entity.id,
      sessionId: entity.sessionId,
      studentId: entity.studentId,
      teacherId: entity.teacherId,
      category: entity.category.value,
      grade: entity.grade,
      notes: entity.notes,
      audioFeedbackUrl: entity.audioFeedbackUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      surahs: entity.surahs,
      verses: entity.verses,
      pagesMemorized: entity.pagesMemorized,
      metadata: entity.metadata,
    );
  }
  final String id;
  final String sessionId;
  final String studentId;
  final String teacherId;
  final String category;
  final int grade;
  final String? notes;
  final String? audioFeedbackUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? surahs;
  final String? verses;
  final int? pagesMemorized;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'teacher_id': teacherId,
      'category': category,
      'grade': grade,
      'notes': notes,
      'audio_feedback_url': audioFeedbackUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'surahs': surahs,
      'verses': verses,
      'pages_memorized': pagesMemorized,
      'metadata': metadata,
    };
  }

  ProgressGrade toEntity() {
    return ProgressGrade(
      id: id,
      sessionId: sessionId,
      studentId: studentId,
      teacherId: teacherId,
      category: GradingCategory.values.firstWhere(
        (c) => c.value == category,
        orElse: () => GradingCategory.memorization,
      ),
      grade: grade,
      notes: notes,
      audioFeedbackUrl: audioFeedbackUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      surahs: surahs,
      verses: verses,
      pagesMemorized: pagesMemorized,
      metadata: metadata,
    );
  }
}
