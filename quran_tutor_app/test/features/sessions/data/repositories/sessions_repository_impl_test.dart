import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/exceptions.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:quran_tutor_app/features/sessions/data/models/session_model.dart';
import 'package:quran_tutor_app/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';

class MockSessionsRemoteDataSource extends Mock implements SessionsRemoteDataSource {}

void main() {
  late SessionsRepositoryImpl repository;
  late MockSessionsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockSessionsRemoteDataSource();
    repository = SessionsRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final tSessionModel = SessionModel(
    id: 'session-1',
    teacherId: 'teacher-1',
    scheduledAt: DateTime.now().toUtc(),
    status: 'scheduled',
    createdAt: DateTime.now().toUtc(),
    durationMinutes: 60,
    topic: 'Surah Al-Fatiha',
  );

  group('getSession', () {
    const tSessionId = 'session-1';

    test('should return Session on success', () async {
      when(() => mockRemoteDataSource.getSession(tSessionId))
          .thenAnswer((_) async => tSessionModel);

      final (session, failure) = await repository.getSession(tSessionId);

      expect(session, isNotNull);
      expect(session!.id, tSessionId);
      expect(failure, isNull);
      verify(() => mockRemoteDataSource.getSession(tSessionId)).called(1);
    });

    test('should return ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.getSession(tSessionId))
          .thenThrow(ServerException.internalError());

      final (session, failure) = await repository.getSession(tSessionId);

      expect(session, isNull);
      expect(failure, isA<ServerFailure>());
    });
  });

  group('getTeacherSessions', () {
    const tTeacherId = 'teacher-1';

    test('should return list of sessions on success', () async {
      when(() => mockRemoteDataSource.getTeacherSessions(tTeacherId))
          .thenAnswer((_) async => [tSessionModel]);

      final (sessions, failure) = await repository.getTeacherSessions(tTeacherId);

      expect(sessions, isNotNull);
      expect(sessions!.length, 1);
      expect(failure, isNull);
    });
  });

  group('createSession', () {
    test('should return Session on success', () async {
      when(() => mockRemoteDataSource.createSession(
        teacherId: any(named: 'teacherId'),
        scheduledAt: any(named: 'scheduledAt'),
        durationMinutes: any(named: 'durationMinutes'),
        topic: any(named: 'topic'),
        notes: any(named: 'notes'),
        location: any(named: 'location'),
        isOnline: any(named: 'isOnline'),
      )).thenAnswer((_) async => tSessionModel);

      final (session, failure) = await repository.createSession(
        teacherId: 'teacher-1',
        scheduledAt: DateTime.now(),
        topic: 'Test Session',
      );

      expect(session, isNotNull);
      expect(failure, isNull);
    });
  });

  group('cancelSession', () {
    const tSessionId = 'session-1';

    test('should return null on success', () async {
      when(() => mockRemoteDataSource.cancelSession(tSessionId, reason: any(named: 'reason')))
          .thenAnswer((_) async {});

      final failure = await repository.cancelSession(tSessionId, reason: 'Test reason');

      expect(failure, isNull);
    });
  });

  group('completeSession', () {
    const tSessionId = 'session-1';

    test('should return completed Session on success', () async {
      final completedModel = tSessionModel.copyWith(status: 'completed');
      when(() => mockRemoteDataSource.completeSession(tSessionId))
          .thenAnswer((_) async => completedModel);

      final (session, failure) = await repository.completeSession(tSessionId);

      expect(session, isNotNull);
      expect(session!.status, SessionStatus.completed);
      expect(failure, isNull);
    });
  });

  group('assignStudent', () {
    test('should return null on success', () async {
      when(() => mockRemoteDataSource.assignStudent('session-1', 'student-1'))
          .thenAnswer((_) async {});

      final failure = await repository.assignStudent(
        sessionId: 'session-1',
        studentId: 'student-1',
      );

      expect(failure, isNull);
    });
  });
}
