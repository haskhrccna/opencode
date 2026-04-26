import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/progress_grade.dart';

/// Data model for grades
class GradeModel {
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

  GradeModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.teacherId,
    required this.category,
    required this.grade,
    this.notes,
    this.audioFeedbackUrl,
    required this.createdAt,
    this.updatedAt,
    this.surahs,
    this.verses,
    this.pagesMemorized,
    this.metadata,
  });

  factory GradeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GradeModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      category: data['category'] ?? 'memorization',
      grade: data['grade'] ?? 1,
      notes: data['notes'],
      audioFeedbackUrl: data['audioFeedbackUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      surahs: data['surahs'] != null
          ? List<String>.from(data['surahs'])
          : null,
      verses: data['verses'],
      pagesMemorized: data['pagesMemorized'],
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  factory GradeModel.fromSupabase(Map<String, dynamic> data) {
    return GradeModel(
      id: data['id'] ?? '',
      sessionId: data['session_id'] ?? '',
      studentId: data['student_id'] ?? '',
      teacherId: data['teacher_id'] ?? '',
      category: data['category'] ?? 'memorization',
      grade: data['grade'] ?? 1,
      notes: data['notes'],
      audioFeedbackUrl: data['audio_feedback_url'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      surahs: data['surahs'] != null
          ? List<String>.from(data['surahs'])
          : null,
      verses: data['verses'],
      pagesMemorized: data['pages_memorized'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'teacherId': teacherId,
      'category': category,
      'grade': grade,
      'notes': notes,
      'audioFeedbackUrl': audioFeedbackUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'surahs': surahs,
      'verses': verses,
      'pagesMemorized': pagesMemorized,
      'metadata': metadata,
    };
  }

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
      category: GradingCategory.fromString(category),
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
}
