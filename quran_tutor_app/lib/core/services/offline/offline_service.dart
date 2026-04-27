import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import '../../../features/sessions/data/models/session_model.dart';
import '../../../features/sessions/domain/entities/session.dart';
import 'offline_database.dart';

/// Service that manages offline caching and sync
@singleton
class OfflineService {
  final OfflineDatabase _db;
  final Connectivity _connectivity;

  bool _isOnline = true;

  OfflineService({
    required OfflineDatabase db,
    required Connectivity connectivity,
  })  : _db = db,
        _connectivity = connectivity {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
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
  Future<void> cacheGrades(List<dynamic> grades) async {
    // Implementation depends on grade model structure
    // Similar to cacheSessions
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
        // This would call the appropriate remote datasource
        await _processSyncItem(item);
        await _db.markSynced(item.id);
      } catch (e) {
        // Keep as pending if sync fails
      }
    }

    // Clean up old synced items
    await _db.clearSyncedItems();
  }

  Future<void> _processSyncItem(SyncQueueEntry item) async {
    // Implementation depends on operation type
    // This is a placeholder for the actual sync logic
    switch (item.tableName) {
      case 'sessions':
        // Handle session sync
        break;
      case 'grades':
        // Handle grade sync
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

  // ignore: unused_element
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
