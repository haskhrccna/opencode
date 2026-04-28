import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart' show GradingCategory;

/// Progress grade entity for tracking student progress
class ProgressGrade extends Equatable {

  const ProgressGrade({
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

  /// Create empty grade
  factory ProgressGrade.empty() => ProgressGrade(
        id: '',
        sessionId: '',
        studentId: '',
        teacherId: '',
        category: GradingCategory.memorization,
        grade: 1,
        createdAt: DateTime.now(),
      );
  final String id;
  final String sessionId;
  final String studentId;
  final String teacherId;
  final GradingCategory category;
  final int grade; // 1-5
  final String? notes;
  final String? audioFeedbackUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? surahs;
  final String? verses;
  final int? pagesMemorized;
  final Map<String, dynamic>? metadata;

  /// Check if has audio feedback
  bool get hasAudioFeedback => audioFeedbackUrl != null && audioFeedbackUrl!.isNotEmpty;

  /// Get grade as percentage (0-100)
  int get gradePercentage => ((grade / 5) * 100).round();

  /// Get grade label
  String get gradeLabel {
    switch (grade) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Good';
      case 3:
        return 'Average';
      case 2:
        return 'Needs Improvement';
      case 1:
        return 'Poor';
      default:
        return 'Not Graded';
    }
  }

  /// Get Arabic grade label
  String get gradeLabelAr {
    switch (grade) {
      case 5:
        return 'ممتاز';
      case 4:
        return 'جيد';
      case 3:
        return 'متوسط';
      case 2:
        return 'يحتاج تحسين';
      case 1:
        return 'ضعيف';
      default:
        return 'غير مقيم';
    }
  }

  /// Get color based on grade
  int get gradeColor {
    switch (grade) {
      case 5:
        return 0xFF4CAF50; // Green
      case 4:
        return 0xFF8BC34A; // Light Green
      case 3:
        return 0xFFFFC107; // Amber
      case 2:
        return 0xFFFF9800; // Orange
      case 1:
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  ProgressGrade copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? teacherId,
    GradingCategory? category,
    int? grade,
    String? notes,
    String? audioFeedbackUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? surahs,
    String? verses,
    int? pagesMemorized,
    Map<String, dynamic>? metadata,
  }) {
    return ProgressGrade(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      category: category ?? this.category,
      grade: grade ?? this.grade,
      notes: notes ?? this.notes,
      audioFeedbackUrl: audioFeedbackUrl ?? this.audioFeedbackUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      surahs: surahs ?? this.surahs,
      verses: verses ?? this.verses,
      pagesMemorized: pagesMemorized ?? this.pagesMemorized,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        studentId,
        teacherId,
        category,
        grade,
        notes,
        audioFeedbackUrl,
        createdAt,
        updatedAt,
        surahs,
        verses,
        pagesMemorized,
        metadata,
      ];
}
