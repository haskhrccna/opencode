import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../lib/core/error/exceptions.dart';
import '../../../../lib/features/sessions/data/datasources/sessions_remote_datasource.dart';
import '../../../../lib/features/sessions/data/models/session_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestQueryBuilder extends Mock
    implements PostgrestQueryBuilder<Map<String, dynamic>> {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<Map<String, dynamic>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {}

void main() {
  late SessionsRemoteDataSource dataSource;
  late MockSupabaseClient mockSupabase;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    when(() => mockSupabase.from(any())).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
    when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
        .thenReturn(mockTransformBuilder);
    when(() => mockFilterBuilder.single()).thenAnswer((_) async => {});

    dataSource = SupabaseSessionsDataSource(supabase: mockSupabase);
  });

  group('getSession', () {
    const tSessionId = 'session-123';

    test('should return SessionModel when session is found', () async {
      // arrange
      final sessionData = {
        'id': tSessionId,
        'teacher_id': 'teacher-1',
        'student_id': 'student-1',
        'scheduled_at': DateTime.now().toIso8601String(),
        'duration_minutes': 60,
        'status': 'scheduled',
        'created_at': DateTime.now().toIso8601String(),
      };
      when(() => mockFilterBuilder.single())
          .thenAnswer((_) async => sessionData);

      // act
      final result = await dataSource.getSession(tSessionId);

      // assert
      expect(result, isNotNull);
      expect(result!.id, tSessionId);
    });

    test('should return null when session is not found', () async {
      // arrange
      when(() => mockFilterBuilder.single())
          .thenThrow(PostgrestException(message: 'Not found'));

      // act & assert
      expect(
        () => dataSource.getSession(tSessionId),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on network error', () async {
      // arrange
      when(() => mockFilterBuilder.single())
          .thenThrow(Exception('Network error'));

      // act & assert
      expect(
        () => dataSource.getSession(tSessionId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getTeacherSessions', () {
    const tTeacherId = 'teacher-123';

    test('should return list of sessions for teacher', () async {
      // arrange
      final sessionsData = [
        {
          'id': 'session-1',
          'teacher_id': tTeacherId,
          'student_id': 'student-1',
          'scheduled_at': DateTime.now().toIso8601String(),
          'duration_minutes': 60,
          'status': 'scheduled',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'session-2',
          'teacher_id': tTeacherId,
          'student_id': 'student-2',
          'scheduled_at': DateTime.now().toIso8601String(),
          'duration_minutes': 45,
          'status': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];
      when(() => mockTransformBuilder.execute())
          .thenAnswer((_) async => sessionsData);
      when(() => mockFilterBuilder.execute())
          .thenAnswer((_) async => sessionsData);

      // act
      final result = await dataSource.getTeacherSessions(tTeacherId);

      // assert
      expect(result, isNotNull);
      expect(result.length, 2);
      verify(() => mockFilterBuilder.eq('teacher_id', tTeacherId)).called(1);
    });

    test('should throw ServerException on error', () async {
      // arrange
      when(() => mockFilterBuilder.execute())
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.getTeacherSessions(tTeacherId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('createSession', () {
    const tTeacherId = 'teacher-123';
    final tScheduledAt = DateTime.now().add(const Duration(days: 1));
    const tDurationMinutes = 60;
    const tTopic = 'Quran Recitation';

    test('should create session and return SessionModel on success', () async {
      // arrange
      final sessionData = {
        'id': 'new-session-id',
        'teacher_id': tTeacherId,
        'student_id': null,
        'scheduled_at': tScheduledAt.toIso8601String(),
        'duration_minutes': tDurationMinutes,
        'topic': tTopic,
        'status': 'scheduled',
        'created_at': DateTime.now().toIso8601String(),
      };

      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenAnswer((_) async => sessionData);

      // act
      final result = await dataSource.createSession(
        teacherId: tTeacherId,
        scheduledAt: tScheduledAt,
        durationMinutes: tDurationMinutes,
        topic: tTopic,
      );

      // assert
      expect(result, isNotNull);
      expect(result.teacherId, tTeacherId);
      expect(result.topic, tTopic);
    });

    test('should throw ServerException when creation fails', () async {
      // arrange
      when(() => mockQueryBuilder.insert(any()))
          .thenThrow(PostgrestException(message: 'Insert failed'));

      // act & assert
      expect(
        () => dataSource.createSession(
          teacherId: tTeacherId,
          scheduledAt: tScheduledAt,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('completeSession', () {
    const tSessionId = 'session-123';

    test('should mark session as completed', () async {
      // arrange
      final sessionData = {
        'id': tSessionId,
        'teacher_id': 'teacher-1',
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final updateBuilder = MockPostgrestFilterBuilder();
      when(() => mockQueryBuilder.update(any())).thenReturn(updateBuilder);
      when(() => updateBuilder.eq(any(), any())).thenReturn(updateBuilder);
      when(() => updateBuilder.select()).thenReturn(updateBuilder);
      when(() => updateBuilder.single()).thenAnswer((_) async => sessionData);

      // act
      final result = await dataSource.completeSession(tSessionId);

      // assert
      expect(result, isNotNull);
      expect(result.status, 'completed');
    });

    test('should throw ServerException on network error', () async {
      // arrange
      final updateBuilder = MockPostgrestFilterBuilder();
      when(() => mockQueryBuilder.update(any())).thenReturn(updateBuilder);
      when(() => updateBuilder.eq(any(), any())).thenThrow(Exception('Network error'));

      // act & assert
      expect(
        () => dataSource.completeSession(tSessionId),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
