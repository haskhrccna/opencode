import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/session.dart';

part 'sessions_state.freezed.dart';

enum SessionsStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  error,
}

@freezed
class SessionsState with _$SessionsState {
  const factory SessionsState({
    required SessionsStatus status,
    List<Session>? sessions,
    Session? selectedSession,
    String? errorMessage,
    DateTime? lastUpdated,
  }) = _SessionsState;

  factory SessionsState.initial() => const SessionsState(
        status: SessionsStatus.initial,
      );
}
