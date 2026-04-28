import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:quran_tutor_app/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_event.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_state.dart';

@injectable
class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {

  SessionsBloc(this._repository) : super(SessionsState.initial()) {
    on<LoadSessions>(_onLoadSessions);
    on<LoadTeacherSessions>(_onLoadTeacherSessions);
    on<LoadStudentSessions>(_onLoadStudentSessions);
    on<LoadAllSessions>(_onLoadAllSessions);
    on<LoadUpcomingSessions>(_onLoadUpcomingSessions);
    on<LoadPastSessions>(_onLoadPastSessions);
    on<GetSession>(_onGetSession);
    on<CreateSession>(_onCreateSession);
    on<AssignStudent>(_onAssignStudent);
    on<UnassignStudent>(_onUnassignStudent);
    on<UpdateSession>(_onUpdateSession);
    on<CancelSession>(_onCancelSession);
    on<RescheduleSession>(_onRescheduleSession);
    on<StartSession>(_onStartSession);
    on<CompleteSession>(_onCompleteSession);
    on<LoadSessionsInRange>(_onLoadSessionsInRange);
    on<RefreshSessions>(_onRefreshSessions);
  }
  final SessionsRepository _repository;

  Future<void> _onLoadSessions(
    LoadSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getAllSessions();

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onLoadTeacherSessions(
    LoadTeacherSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getTeacherSessions(event.teacherId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onLoadStudentSessions(
    LoadStudentSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getStudentSessions(event.studentId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onLoadAllSessions(
    LoadAllSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getAllSessions();

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onLoadUpcomingSessions(
    LoadUpcomingSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getUpcomingSessions(userId: event.userId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onLoadPastSessions(
    LoadPastSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getPastSessions(userId: event.userId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onGetSession(
    GetSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (session, failure) = await _repository.getSession(event.sessionId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        selectedSession: session,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onCreateSession(
    CreateSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.creating));

    final (session, failure) = await _repository.createSession(
      teacherId: event.teacherId,
      scheduledAt: event.scheduledAt,
      durationMinutes: event.durationMinutes,
      topic: event.topic,
      notes: event.notes,
      location: event.location,
      isOnline: event.isOnline,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      // Refresh sessions list
      add(const LoadSessions());
    }
  }

  Future<void> _onAssignStudent(
    AssignStudent event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    final failure = await _repository.assignStudent(
      sessionId: event.sessionId,
      studentId: event.studentId,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      add(GetSession(event.sessionId));
    }
  }

  Future<void> _onUnassignStudent(
    UnassignStudent event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    final failure = await _repository.unassignStudent(event.sessionId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      add(GetSession(event.sessionId));
    }
  }

  Future<void> _onUpdateSession(
    UpdateSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    // Get current session first
    final (currentSession, _) = await _repository.getSession(event.sessionId);
    if (currentSession == null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: 'Session not found',
      ),);
      return;
    }

    // Create updated session
    final updatedSession = currentSession.copyWith(
      scheduledAt: event.scheduledAt,
      durationMinutes: event.durationMinutes,
      topic: event.topic,
      notes: event.notes,
      location: event.location,
      isOnline: event.isOnline,
    );

    final (session, failure) = await _repository.updateSession(updatedSession);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        selectedSession: session,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onCancelSession(
    CancelSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    final failure = await _repository.cancelSession(
      event.sessionId,
      reason: event.reason,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      add(GetSession(event.sessionId));
    }
  }

  Future<void> _onRescheduleSession(
    RescheduleSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    final (session, failure) = await _repository.rescheduleSession(
      sessionId: event.sessionId,
      newScheduledAt: event.newScheduledAt,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        selectedSession: session,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    final (session, failure) = await _repository.startSession(event.sessionId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        selectedSession: session,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onCompleteSession(
    CompleteSession event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.updating));

    final (session, failure) = await _repository.completeSession(event.sessionId);

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        selectedSession: session,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onLoadSessionsInRange(
    LoadSessionsInRange event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getSessionsInRange(
      start: event.start,
      end: event.end,
      userId: event.userId,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }

  Future<void> _onRefreshSessions(
    RefreshSessions event,
    Emitter<SessionsState> emit,
  ) async {
    emit(state.copyWith(status: SessionsStatus.loading));

    final (sessions, failure) = await _repository.getAllSessions();

    if (failure != null) {
      emit(state.copyWith(
        status: SessionsStatus.error,
        errorMessage: failure.message,
      ),);
    } else {
      emit(state.copyWith(
        status: SessionsStatus.loaded,
        sessions: sessions,
        lastUpdated: DateTime.now(),
      ),);
    }
  }
}
