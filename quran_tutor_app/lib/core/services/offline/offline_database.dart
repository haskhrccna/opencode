import 'package:drift/drift.dart';

part 'offline_database.g.dart';

@DataClassName('CachedSession')
class CachedSessions extends Table {
  TextColumn get id => text()();
  TextColumn get teacherId => text()();
  TextColumn get studentId => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get topic => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedGrade')
class CachedGrades extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get studentId => text()();
  TextColumn get teacherId => text()();
  TextColumn get category => text()();
  IntColumn get grade => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get operation => text()();
  TextColumn get recordId => text()();
  TextColumn get data => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [CachedSessions, CachedGrades, SyncQueue])
class OfflineDatabase extends _$OfflineDatabase {
  OfflineDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'quran_tutor_offline');
  }

  // Sessions cache operations
  Future<void> cacheSessions(List<CachedSession> sessions) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        cachedSessions,
        sessions.map((s) => s.toCompanion(false)).toList(),
      );
    });
  }

  Future<List<CachedSession>> getCachedSessions({String? userId}) async {
    if (userId != null) {
      return await (select(cachedSessions)
            ..where((s) => s.teacherId.equals(userId) | s.studentId.equals(userId)))
          .get();
    }
    return await select(cachedSessions).get();
  }

  Future<CachedSession?> getCachedSessionById(String sessionId) async {
    return await (select(cachedSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();
  }

  Future<void> deleteCachedSession(String sessionId) async {
    await (delete(cachedSessions)..where((s) => s.id.equals(sessionId))).go();
  }

  // Grades cache operations
  Future<void> cacheGrades(List<CachedGrade> grades) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        cachedGrades,
        grades.map((g) => g.toCompanion(false)).toList(),
      );
    });
  }

  Future<List<CachedGrade>> getCachedGrades({String? studentId}) async {
    if (studentId != null) {
      return await (select(cachedGrades)
            ..where((g) => g.studentId.equals(studentId)))
          .get();
    }
    return await select(cachedGrades).get();
  }

  Future<void> deleteCachedGrade(String gradeId) async {
    await (delete(cachedGrades)..where((g) => g.id.equals(gradeId))).go();
  }

  // Sync queue operations
  Future<void> addToSyncQueue({
    required String table,
    required String operation,
    required String recordId,
    String? data,
  }) async {
    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        tableName: table,
        operation: operation,
        recordId: recordId,
        data: Value(data),
      ),
    );
  }

  Future<List<SyncQueueEntry>> getPendingSyncItems() async {
    return await (select(syncQueue)..where((s) => s.isSynced.equals(false))).get();
  }

  Future<void> markSynced(int entryId) async {
    await update(syncQueue).replace(
      SyncQueueCompanion(
        id: Value(entryId),
        isSynced: const Value(true),
      ),
    );
  }

  Future<void> clearSyncedItems() async {
    await (delete(syncQueue)..where((s) => s.isSynced.equals(true))).go();
  }

  Future<DateTime?> getLastSyncTime() async {
    final sessions = await select(cachedSessions).get();
    if (sessions.isEmpty) return null;
    return sessions.map((s) => s.syncedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
