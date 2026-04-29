import 'package:equatable/equatable.dart';

import 'package:quran_tutor_app/features/sessions/domain/entities/session.dart';

enum SessionsStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  error,
}

class SessionsState extends Equatable {
  const SessionsState({
    required this.status,
    this.sessions,
    this.selectedSession,
    this.errorMessage,
    this.lastUpdated,
  });

  factory SessionsState.initial() => const SessionsState(
        status: SessionsStatus.initial,
      );
  final SessionsStatus status;
  final List<Session>? sessions;
  final Session? selectedSession;
  final String? errorMessage;
  final DateTime? lastUpdated;

  SessionsState copyWith({
    SessionsStatus? status,
    List<Session>? sessions,
    Session? selectedSession,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return SessionsState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      selectedSession: selectedSession ?? this.selectedSession,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sessions,
        selectedSession,
        errorMessage,
        lastUpdated,
      ];
}
