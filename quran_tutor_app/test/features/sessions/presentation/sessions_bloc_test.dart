import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';
import 'package:quran_tutor_app/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_event.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_state.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late SessionsBloc bloc;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    bloc = SessionsBloc(mockRepository);
  });

  tearDown(() => bloc.close());

  final tSession = Session(
    id: 'session-1',
    teacherId: 'teacher-1',
    scheduledAt: DateTime.now().toUtc(),
    status: SessionStatus.scheduled,
    createdAt: DateTime.now().toUtc(),
    durationMinutes: 60,
    topic: 'Surah Al-Fatiha',
  );

  group('LoadSessions', () {
    blocTest<SessionsBloc, SessionsState>(
      'emits [loading, loaded] when sessions load successfully',
      build: () {
        when(() => mockRepository.getAllSessions())
            .thenAnswer((_) async => ([tSession], null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSessions()),
      expect: () => [
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loading),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loaded)
            .having((s) => s.sessions?.length, 'sessions.length', 1),
      ],
    );

    blocTest<SessionsBloc, SessionsState>(
      'emits [loading, error] when sessions fail to load',
      build: () {
        when(() => mockRepository.getAllSessions())
            .thenAnswer((_) async => (null, ServerFailure.internalError()));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSessions()),
      expect: () => [
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loading),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.error)
            .having(
                (s) => s.errorMessage, 'errorMessage', 'Internal server error'),
      ],
    );
  });

  group('GetSession', () {
    blocTest<SessionsBloc, SessionsState>(
      'emits [loading, loaded] when session is retrieved',
      build: () {
        when(() => mockRepository.getSession('session-1'))
            .thenAnswer((_) async => (tSession, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetSession('session-1')),
      expect: () => [
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loading),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loaded)
            .having((s) => s.selectedSession?.id, 'selectedSession.id',
                'session-1'),
      ],
    );
  });

  group('CreateSession', () {
    blocTest<SessionsBloc, SessionsState>(
      'emits creating then dispatches LoadSessions after success',
      build: () {
        when(() => mockRepository.createSession(
              teacherId: any(named: 'teacherId'),
              scheduledAt: any(named: 'scheduledAt'),
              durationMinutes: any(named: 'durationMinutes'),
              topic: any(named: 'topic'),
              notes: any(named: 'notes'),
              location: any(named: 'location'),
              isOnline: any(named: 'isOnline'),
            )).thenAnswer((_) async => (tSession, null));
        when(() => mockRepository.getAllSessions())
            .thenAnswer((_) async => ([tSession], null));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateSession(
        teacherId: 'teacher-1',
        scheduledAt: DateTime.now(),
        topic: 'Test',
      )),
      expect: () => [
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.creating),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loading),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loaded)
            .having((s) => s.sessions?.length, 'sessions.length', 1),
      ],
    );
  });

  group('CancelSession', () {
    blocTest<SessionsBloc, SessionsState>(
      'emits updating then reloads session',
      build: () {
        when(() => mockRepository.cancelSession('session-1',
            reason: any(named: 'reason'))).thenAnswer((_) async => null);
        when(() => mockRepository.getSession('session-1'))
            .thenAnswer((_) async => (tSession, null));
        return bloc;
      },
      act: (bloc) => bloc.add(const CancelSession(sessionId: 'session-1')),
      expect: () => [
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.updating),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loading),
        isA<SessionsState>()
            .having((s) => s.status, 'status', SessionsStatus.loaded)
            .having((s) => s.selectedSession?.id, 'selectedSession.id',
                'session-1'),
      ],
    );
  });
}
