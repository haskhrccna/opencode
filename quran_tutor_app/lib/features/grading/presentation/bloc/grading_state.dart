import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/progress_grade.dart';
import '../../domain/repositories/grading_repository.dart';

part 'grading_state.freezed.dart';

enum GradingStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  error,
}

@freezed
class GradingState with _$GradingState {
  const factory GradingState({
    required GradingStatus status,
    List<ProgressGrade>? grades,
    ProgressGrade? selectedGrade,
    ProgressSummary? progressSummary,
    ProgressTimeline? progressTimeline,
    List<StudentProgress>? classProgress,
    String? errorMessage,
    DateTime? lastUpdated,
  }) = _GradingState;

  factory GradingState.initial() => const GradingState(
        status: GradingStatus.initial,
      );
}
