/// Offline database stub - drift code generation not available
/// 
/// This is a temporary implementation that stores data in memory.
/// For production, run: flutter pub run build_runner build
/// to generate the real drift database.

import 'package:injectable/injectable.dart';

class CachedSession {

  CachedSession({
    required this.id,
    required this.teacherId,
    required this.scheduledAt, required this.durationMinutes, required this.status, required this.createdAt, required this.syncedAt, this.studentId,
    this.topic,
    this.notes,
  });
  final String id;
  final String teacherId;
  final String? studentId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? topic;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime syncedAt;
}

class CachedGrade {

  CachedGrade({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.teacherId,
    required this.category,
    required this.grade,
    required this.createdAt, required this.syncedAt, this.notes,
  });
  final String id;
  final String sessionId;
  final String studentId;
  final String teacherId;
  final String category;
  final int grade;
  final String? notes;
  final DateTime createdAt;
  final DateTime syncedAt;
}

class SyncQueueEntry {

  SyncQueueEntry({
    required this.id,
    required this.tableName,
    required this.operation,
    required this.recordId,
    required this.createdAt, required this.isSynced, this.data,
  });
  final int id;
  final String tableName;
  final String operation;
  final String recordId;
  final String? data;
  final DateTime createdAt;
  final bool isSynced;
}

/// Stub implementation of offline database
@singleton
class OfflineDatabase {
  final List<CachedSession> _sessions = [];
  final List<CachedGrade> _grades = [];
  final List<SyncQueueEntry> _syncQueue = [];
  int _nextSyncId = 1;

  // Sessions
  Future<void> cacheSessions(List<CachedSession> sessions) async {
    _sessions.removeWhere((s) => sessions.any((newS) => newS.id == s.id));
    _sessions.addAll(sessions);
  }

  Future<List<CachedSession>> getCachedSessions({String? userId}) async {
    if (userId != null) {
      return _sessions
          .where((s) => s.teacherId == userId || s.studentId == userId)
          .toList();
    }
    return List.unmodifiable(_sessions);
  }

  Future<CachedSession?> getCachedSessionById(String sessionId) async {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteCachedSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  // Grades
  Future<void> cacheGrades(List<CachedGrade> grades) async {
    _grades.removeWhere((g) => grades.any((newG) => newG.id == g.id));
    _grades.addAll(grades);
  }

  Future<List<CachedGrade>> getCachedGrades({String? studentId}) async {
    if (studentId != null) {
      return _grades.where((g) => g.studentId == studentId).toList();
    }
    return List.unmodifiable(_grades);
  }

  Future<void> deleteCachedGrade(String gradeId) async {
    _grades.removeWhere((g) => g.id == gradeId);
  }

  // Sync Queue
  Future<void> addToSyncQueue({
    required String table,
    required String operation,
    required String recordId,
    String? data,
  }) async {
    _syncQueue.add(SyncQueueEntry(
      id: _nextSyncId++,
      tableName: table,
      operation: operation,
      recordId: recordId,
      data: data,
      createdAt: DateTime.now(),
      isSynced: false,
    ),);
  }

  Future<List<SyncQueueEntry>> getPendingSyncItems() async {
    return _syncQueue.where((s) => !s.isSynced).toList();
  }

  Future<void> markSynced(int entryId) async {
    final index = _syncQueue.indexWhere((s) => s.id == entryId);
    if (index >= 0) {
      final old = _syncQueue[index];
      _syncQueue[index] = SyncQueueEntry(
        id: old.id,
        tableName: old.tableName,
        operation: old.operation,
        recordId: old.recordId,
        data: old.data,
        createdAt: old.createdAt,
        isSynced: true,
      );
    }
  }

  Future<void> clearSyncedItems() async {
    _syncQueue.removeWhere((s) => s.isSynced);
  }

  Future<DateTime?> getLastSyncTime() async {
    if (_sessions.isEmpty) return null;
    return _sessions.map((s) => s.syncedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
