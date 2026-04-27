import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../entities/progress_grade.dart';

/// Repository interface for grading operations
abstract class GradingRepository {
  /// Get grade by ID
  Future<(ProgressGrade?, Failure?)> getGrade(String gradeId);

  /// Get grades for a session
  Future<(List<ProgressGrade>?, Failure?)> getGradesBySession(String sessionId);

  /// Get grades for a student
  Future<(List<ProgressGrade>?, Failure?)> getGradesByStudent(String studentId);

  /// Get grades by teacher
  Future<(List<ProgressGrade>?, Failure?)> getGradesByTeacher(String teacherId);

  /// Get latest grades for a student
  Future<(List<ProgressGrade>?, Failure?)> getLatestGradesByStudent(
    String studentId, {
    int limit = 10,
  });

  /// Create new grade
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
  });

  /// Update grade
  Future<(ProgressGrade?, Failure?)> updateGrade(ProgressGrade grade);

  /// Delete grade
  Future<Failure?> deleteGrade(String gradeId);

  /// Upload audio feedback
  ///
  /// Returns updated grade with audio URL
  Future<(ProgressGrade?, Failure?)> uploadAudioFeedback({
    required String gradeId,
    required String audioFilePath,
  });

  /// Delete audio feedback
  Future<Failure?> deleteAudioFeedback(String gradeId);

  /// Get student progress summary
  Future<(ProgressSummary?, Failure?)> getStudentProgressSummary(String studentId);

  /// Get progress over time
  Future<(ProgressTimeline?, Failure?)> getProgressTimeline({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get class/group progress
  Future<(List<StudentProgress>?, Failure?)> getClassProgress(String teacherId);

  /// Stream of grades for real-time updates
  Stream<List<ProgressGrade>> get gradesStream;
}

/// Progress summary for a student
class ProgressSummary extends Equatable {
  final String studentId;
  final int totalSessions;
  final int sessionsGraded;
  final double averageGrade;
  final Map<GradingCategory, double> categoryAverages;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSessionDate;
  final int totalPagesMemorized;
  final List<String> surahsMemorized;

  const ProgressSummary({
    required this.studentId,
    required this.totalSessions,
    required this.sessionsGraded,
    required this.averageGrade,
    required this.categoryAverages,
    required this.currentStreak,
    required this.longestStreak,
    this.lastSessionDate,
    required this.totalPagesMemorized,
    required this.surahsMemorized,
  });

  @override
  List<Object?> get props => [
        studentId,
        totalSessions,
        sessionsGraded,
        averageGrade,
        categoryAverages,
        currentStreak,
        longestStreak,
        lastSessionDate,
        totalPagesMemorized,
        surahsMemorized,
      ];
}

/// Progress timeline for charting
class ProgressTimeline extends Equatable {
  final String studentId;
  final List<ProgressPoint> points;

  const ProgressTimeline({
    required this.studentId,
    required this.points,
  });

  @override
  List<Object?> get props => [studentId, points];
}

/// Single progress data point
class ProgressPoint extends Equatable {
  final DateTime date;
  final double averageGrade;
  final int sessionsCount;

  const ProgressPoint({
    required this.date,
    required this.averageGrade,
    required this.sessionsCount,
  });

  @override
  List<Object?> get props => [date, averageGrade, sessionsCount];
}

/// Student progress for class overview
class StudentProgress extends Equatable {
  final String studentId;
  final String? studentName;
  final double averageGrade;
  final int sessionsAttended;
  final int sessionsTotal;
  final DateTime? lastSession;
  final bool isOnTrack;

  const StudentProgress({
    required this.studentId,
    this.studentName,
    required this.averageGrade,
    required this.sessionsAttended,
    required this.sessionsTotal,
    this.lastSession,
    this.isOnTrack = true,
  });

  double get attendanceRate => sessionsTotal > 0
      ? (sessionsAttended / sessionsTotal) * 100
      : 0;

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        averageGrade,
        sessionsAttended,
        sessionsTotal,
        lastSession,
        isOnTrack,
      ];
}
