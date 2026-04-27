import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/grading_repository.dart';
import 'grading_event.dart';
import 'grading_state.dart';

@injectable
class GradingBloc extends Bloc<GradingEvent, GradingState> {
  final GradingRepository _repository;

  GradingBloc(this._repository) : super(GradingState.initial()) {
    on<LoadGrades>(_onLoadGrades);
    on<LoadGradesBySession>(_onLoadGradesBySession);
    on<LoadGradesByTeacher>(_onLoadGradesByTeacher);
    on<GetGrade>(_onGetGrade);
    on<CreateGrade>(_onCreateGrade);
    on<UpdateGrade>(_onUpdateGrade);
    on<DeleteGrade>(_onDeleteGrade);
    on<LoadStudentProgress>(_onLoadStudentProgress);
    on<LoadProgressTimeline>(_onLoadProgressTimeline);
    on<LoadClassProgress>(_onLoadClassProgress);
    on<UploadAudioFeedback>(_onUploadAudioFeedback);
    on<RefreshGrades>(_onRefreshGrades);
  }

  Future<void> _onLoadGrades(
    LoadGrades event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    if (event.studentId == null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: 'Student ID required',
      ));
      return;
    }

    final (grades, failure) = await _repository.getGradesByStudent(event.studentId!);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final chartData = grades != null ? ChartData.fromGrades(grades) : null;
      emit(state.copyWith(
        status: GradingStatus.loaded,
        grades: grades,
        chartData: chartData,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadGradesBySession(
    LoadGradesBySession event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    final (grades, failure) = await _repository.getGradesBySession(event.sessionId);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        grades: grades,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadGradesByTeacher(
    LoadGradesByTeacher event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    final (grades, failure) = await _repository.getGradesByTeacher(event.teacherId);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        grades: grades,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onGetGrade(
    GetGrade event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    final (grade, failure) = await _repository.getGrade(event.gradeId);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        selectedGrade: grade,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onCreateGrade(
    CreateGrade event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.creating));

    final (grade, failure) = await _repository.createGrade(
      sessionId: event.sessionId,
      studentId: event.studentId,
      teacherId: event.teacherId,
      category: event.category,
      grade: event.grade,
      notes: event.notes,
      surahs: event.surahs,
      verses: event.verses,
      pagesMemorized: event.pagesMemorized,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        selectedGrade: grade,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onUpdateGrade(
    UpdateGrade event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.updating));

    // Get current grade first
    final (currentGrade, _) = await _repository.getGrade(event.gradeId);
    if (currentGrade == null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: 'Grade not found',
      ));
      return;
    }

    // Update with new values
    final updatedGrade = currentGrade.copyWith(
      grade: event.grade,
      notes: event.notes,
      surahs: event.surahs,
      verses: event.verses,
      pagesMemorized: event.pagesMemorized,
    );

    final (grade, failure) = await _repository.updateGrade(updatedGrade);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        selectedGrade: grade,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onDeleteGrade(
    DeleteGrade event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.deleting));

    final failure = await _repository.deleteGrade(event.gradeId);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        selectedGrade: null,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadStudentProgress(
    LoadStudentProgress event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    final (summary, failure) = await _repository.getStudentProgressSummary(event.studentId);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        progressSummary: summary,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadProgressTimeline(
    LoadProgressTimeline event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    final (timeline, failure) = await _repository.getProgressTimeline(
      studentId: event.studentId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        progressTimeline: timeline,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadClassProgress(
    LoadClassProgress event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    final (progress, failure) = await _repository.getClassProgress(event.teacherId);

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      emit(state.copyWith(
        status: GradingStatus.loaded,
        classProgress: progress,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onUploadAudioFeedback(
    UploadAudioFeedback event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.updating));

    final (grade, failure) = await _repository.uploadAudioFeedback(
      gradeId: event.gradeId,
      audioFilePath: event.audioFilePath,
    );

    if (failure != null) {
      emit(state.copyWith(
        status: GradingStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      // Refresh the grade
      add(GetGrade(event.gradeId));
    }
  }

  Future<void> _onRefreshGrades(
    RefreshGrades event,
    Emitter<GradingState> emit,
  ) async {
    emit(state.copyWith(status: GradingStatus.loading));

    // This would need to know what to refresh
    // For now, just clear the state
    emit(GradingState.initial());
  }
}
