import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../features/grading/data/datasources/grading_remote_datasource.dart';
import '../../../features/grading/data/models/grade_model.dart';
import '../../../features/sessions/data/datasources/sessions_remote_datasource.dart';
import '../../../features/sessions/data/models/session_model.dart';
import '../../../features/sessions/domain/entities/session.dart';
import 'offline_database.dart';

/// Service that manages offline caching and sync
@singleton
class OfflineService {
  final OfflineDatabase _db;
  final Connectivity _connectivity;
  SessionsRemoteDataSource? _sessionsDataSource;
  GradingRemoteDataSource? _gradingDataSource;

  bool _isOnline = true;

  OfflineService({
    required OfflineDatabase db,
    required Connectivity connectivity,
    SessionsRemoteDataSource? sessionsDataSource,
    GradingRemoteDataSource? gradingDataSource,
  })  : _db = db,
        _connectivity = connectivity,
        _sessionsDataSource = sessionsDataSource,
        _gradingDataSource = gradingDataSource {
    _initConnectivity();
  }

  /// Set datasources after initialization (for DI)
  void setDataSources({
    SessionsRemoteDataSource? sessions,
    GradingRemoteDataSource? grading,
  }) {
    _sessionsDataSource = sessions;
    _gradingDataSource = grading;
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = !result.contains(ConnectivityResult.none);
      if (_isOnline) {
        syncPendingChanges();
      }
    });
  }

  bool get isOnline => _isOnline;

  /// Cache sessions locally
  Future<void> cacheSessions(List<SessionModel> sessions) async {
    final cached = sessions.map((s) {
      return CachedSession(
        id: s.id,
        teacherId: s.teacherId,
        studentId: s.studentId,
        scheduledAt: s.scheduledAt,
        durationMinutes: s.durationMinutes,
        topic: s.topic,
        notes: s.notes,
        status: s.status,
        createdAt: s.createdAt,
        syncedAt: DateTime.now(),
      );
    }).toList();

    await _db.cacheSessions(cached);
  }

  /// Get cached sessions
  Future<List<Session>> getCachedSessions({String? userId}) async {
    final cached = await _db.getCachedSessions(userId: userId);
    return cached.map((c) => _mapCachedSessionToEntity(c)).toList();
  }

  /// Check if we have cached sessions
  Future<bool> hasCachedSessions() async {
    final sessions = await _db.getCachedSessions();
    return sessions.isNotEmpty;
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    return _db.getLastSyncTime();
  }

  /// Cache grades locally
  Future<void> cacheGrades(List<GradeModel> grades) async {
    final cached = grades.map((g) {
      return CachedGrade(
        id: g.id,
        sessionId: g.sessionId,
        studentId: g.studentId,
        teacherId: g.teacherId,
        category: g.category,
        grade: g.grade,
        notes: g.notes,
        createdAt: g.createdAt,
        syncedAt: DateTime.now(),
      );
    }).toList();

    await _db.cacheGrades(cached);
  }

  /// Get cached grades
  Future<List<CachedGrade>> getCachedGrades({String? studentId}) async {
    return await _db.getCachedGrades(studentId: studentId);
  }

  /// Queue an operation for when online
  Future<void> queueOperation({
    required String table,
    required String operation,
    required String recordId,
    String? data,
  }) async {
    await _db.addToSyncQueue(
      table: table,
      operation: operation,
      recordId: recordId,
      data: data,
    );
  }

  /// Sync pending changes
  Future<void> syncPendingChanges() async {
    final pending = await _db.getPendingSyncItems();

    for (final item in pending) {
      try {
        // Process each pending operation
        await _processSyncItem(item);
        await _db.markSynced(item.id);
      } catch (e) {
        // Keep as pending if sync fails
        // Don't mark as synced
      }
    }

    // Clean up old synced items
    await _db.clearSyncedItems();
  }

  Future<void> _processSyncItem(SyncQueueEntry item) async {
    switch (item.tableName) {
      case 'sessions':
        await _processSessionSync(item);
        break;
      case 'grades':
        await _processGradeSync(item);
        break;
      default:
        // Unknown table, mark as processed to avoid endless retries
        break;
    }
  }

  Future<void> _processSessionSync(SyncQueueEntry item) async {
    if (_sessionsDataSource == null) {
      throw Exception('Sessions data source not configured');
    }

    final data = item.data != null ? jsonDecode(item.data!) as Map<String, dynamic> : null;

    switch (item.operation) {
      case 'create':
        if (data != null) {
          final session = SessionModel.fromSupabase(data);
          await _sessionsDataSource!.createSession(
            teacherId: session.teacherId,
            scheduledAt: session.scheduledAt,
            durationMinutes: session.durationMinutes,
            topic: session.topic,
            notes: session.notes,
            location: session.location,
            isOnline: session.isOnline,
          );
        }
        break;
      case 'update':
        if (data != null) {
          final session = SessionModel.fromSupabase(data);
          await _sessionsDataSource!.updateSession(session);
        }
        break;
      case 'delete':
      case 'cancel':
        await _sessionsDataSource!.cancelSession(item.recordId);
        break;
      default:
        break;
    }
  }

  Future<void> _processGradeSync(SyncQueueEntry item) async {
    if (_gradingDataSource == null) {
      throw Exception('Grading data source not configured');
    }

    final data = item.data != null ? jsonDecode(item.data!) as Map<String, dynamic> : null;

    switch (item.operation) {
      case 'create':
        if (data != null) {
          final grade = GradeModel.fromSupabase(data);
          await _gradingDataSource!.createGrade(
            sessionId: grade.sessionId,
            studentId: grade.studentId,
            teacherId: grade.teacherId,
            category: GradingCategory.values.byName(grade.category),
            grade: grade.grade,
            notes: grade.notes,
            surahs: grade.surahs,
            verses: grade.verses,
            pagesMemorized: grade.pagesMemorized,
          );
        }
        break;
      case 'delete':
        await _gradingDataSource!.deleteGrade(item.recordId);
        break;
      default:
        break;
    }
  }

  Session _mapCachedSessionToEntity(CachedSession cached) {
    return Session(
      id: cached.id,
      teacherId: cached.teacherId,
      studentId: cached.studentId,
      scheduledAt: cached.scheduledAt,
      durationMinutes: cached.durationMinutes,
      topic: cached.topic,
      notes: cached.notes,
      status: _parseStatus(cached.status),
      createdAt: cached.createdAt,
    );
  }

  SessionStatus _parseStatus(String status) {
    switch (status) {
      case 'scheduled':
        return SessionStatus.scheduled;
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'rescheduled':
        return SessionStatus.rescheduled;
      default:
        return SessionStatus.scheduled;
    }
  }
}

/// Extension to check if data is stale
extension StaleDataCheck on DateTime? {
  bool get isStale {
    if (this == null) return true;
    final age = DateTime.now().difference(this!);
    return age > const Duration(hours: 24); // Data older than 24 hours is stale
  }
}
