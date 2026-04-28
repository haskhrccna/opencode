import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/features/grading/data/models/grade_model.dart';
import 'package:quran_tutor_app/features/grading/domain/repositories/grading_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract remote datasource for grading
abstract class GradingRemoteDataSource {
  /// Get grade by ID
  Future<GradeModel?> getGrade(String gradeId);

  /// Get grades by session
  Future<List<GradeModel>> getGradesBySession(String sessionId);

  /// Get grades by student
  Future<List<GradeModel>> getGradesByStudent(String studentId);

  /// Get grades by teacher
  Future<List<GradeModel>> getGradesByTeacher(String teacherId);

  /// Create grade
  Future<GradeModel> createGrade({
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
  Future<GradeModel> updateGrade(GradeModel grade);

  /// Delete grade
  Future<void> deleteGrade(String gradeId);

  /// Upload audio feedback
  Future<String> uploadAudioFeedback(String gradeId, String audioFilePath);

  /// Delete audio feedback
  Future<void> deleteAudioFeedback(String gradeId);

  /// Get student progress summary
  Future<ProgressSummary> getStudentProgressSummary(String studentId);

  /// Get progress timeline
  Future<ProgressTimeline> getProgressTimeline({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get class progress
  Future<List<StudentProgress>> getClassProgress(String teacherId);

  /// Stream of grade changes
  Stream<List<GradeModel>> gradesStream({String? studentId});
}

/// Supabase implementation
@Singleton(as: GradingRemoteDataSource)
class SupabaseGradingDataSource implements GradingRemoteDataSource {

  SupabaseGradingDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  final SupabaseClient _supabase;

  @override
  Future<GradeModel?> getGrade(String gradeId) async {
    try {
      final response = await _supabase
          .from('grades')
          .select()
          .eq('id', gradeId)
          .single();

      return GradeModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<GradeModel>> getGradesBySession(String sessionId) async {
    try {
      final response = await _supabase
          .from('grades')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => GradeModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<GradeModel>> getGradesByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('grades')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => GradeModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<GradeModel>> getGradesByTeacher(String teacherId) async {
    try {
      final response = await _supabase
          .from('grades')
          .select()
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => GradeModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<GradeModel> createGrade({
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
      final data = {
        'session_id': sessionId,
        'student_id': studentId,
        'teacher_id': teacherId,
        'category': category.value,
        'grade': grade,
        'notes': notes,
        'surahs': surahs,
        'verses': verses,
        'pages_memorized': pagesMemorized,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _supabase
          .from('grades')
          .insert(data)
          .select()
          .single();

      return GradeModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<GradeModel> updateGrade(GradeModel grade) async {
    try {
      final data = grade.toSupabase();
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();

      final response = await _supabase
          .from('grades')
          .update(data)
          .eq('id', grade.id)
          .select()
          .single();

      return GradeModel.fromSupabase(response);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> deleteGrade(String gradeId) async {
    try {
      await _supabase
          .from('grades')
          .delete()
          .eq('id', gradeId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<String> uploadAudioFeedback(String gradeId, String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      final fileName = 'feedback/$gradeId.mp3';

      await _supabase.storage
          .from('grades')
          .upload(fileName, file);

      final url = _supabase.storage
          .from('grades')
          .getPublicUrl(fileName);

      // Update grade with audio URL
      await _supabase
          .from('grades')
          .update({'audio_feedback_url': url})
          .eq('id', gradeId);

      return url;
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<void> deleteAudioFeedback(String gradeId) async {
    try {
      final fileName = 'feedback/$gradeId.mp3';
      await _supabase.storage.from('grades').remove([fileName]);

      await _supabase
          .from('grades')
          .update({'audio_feedback_url': null})
          .eq('id', gradeId);
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<ProgressSummary> getStudentProgressSummary(String studentId) async {
    try {
      // Call Supabase RPC function
      final response = await _supabase
        .rpc<Map<String, dynamic>>('get_student_progress_summary', params: {
        'student_id': studentId,
      },);

      return ProgressSummary(
        studentId: studentId,
        totalSessions: (response['total_sessions'] as num?)?.toInt() ?? 0,
        sessionsGraded: (response['sessions_graded'] as num?)?.toInt() ?? 0,
        averageGrade: (response['average_grade'] as num?)?.toDouble() ?? 0.0,
        categoryAverages: const {},
        currentStreak: (response['current_streak'] as num?)?.toInt() ?? 0,
        longestStreak: (response['longest_streak'] as num?)?.toInt() ?? 0,
        lastSessionDate: response['last_session_date'] != null
            ? DateTime.parse(response['last_session_date'] as String)
            : null,
        totalPagesMemorized: (response['total_pages_memorized'] as num?)?.toInt() ?? 0,
        surahsMemorized: List<String>.from((response['surahs_memorized'] as List?) ?? []),
      );
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<ProgressTimeline> getProgressTimeline({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
    final response = await _supabase
        .rpc<List<dynamic>>('get_progress_timeline', params: {
      'student_id': studentId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    },);

    final points = response
        .map((e) => ProgressPoint(
              date: DateTime.parse((e as Map<String, dynamic>)['date'] as String),
              averageGrade: (e['average_grade'] as num?)?.toDouble() ?? 0.0,
              sessionsCount: (e['sessions_count'] as num?)?.toInt() ?? 0,
            ),)
        .toList();

      return ProgressTimeline(
        studentId: studentId,
        points: points,
      );
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Future<List<StudentProgress>> getClassProgress(String teacherId) async {
    try {
    final response = await _supabase
        .rpc<List<dynamic>>('get_class_progress', params: {
      'teacher_id': teacherId,
    },);

    return response
        .map((e) => StudentProgress(
              studentId: (e as Map<String, dynamic>)['student_id'] as String,
              studentName: e['student_name'] as String? ?? '',
              averageGrade: (e['average_grade'] as num?)?.toDouble() ?? 0.0,
              sessionsAttended: (e['sessions_attended'] as num?)?.toInt() ?? 0,
              sessionsTotal: (e['sessions_total'] as num?)?.toInt() ?? 0,
              lastSession: e['last_session'] != null
                  ? DateTime.parse(e['last_session'] as String)
                  : null,
              isOnTrack: (e['is_on_track'] as bool?) ?? true,
            ),)
        .toList();
    } catch (e) {
      throw ServerException.internalError();
    }
  }

  @override
  Stream<List<GradeModel>> gradesStream({String? studentId}) {
    var query = _supabase.from('grades').stream(primaryKey: ['id']);
    if (studentId != null && studentId.isNotEmpty) {
      query = query.eq('student_id', studentId);
    }
    return query.map((data) => data
        .map((e) => GradeModel.fromSupabase(e as Map<String, dynamic>))
        .toList());
  }
}
