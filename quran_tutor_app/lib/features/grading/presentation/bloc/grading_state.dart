import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/progress_grade.dart';
import '../../domain/repositories/grading_repository.dart';

enum GradingStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  error,
}

/// Chart data for progress visualization
class ChartData extends Equatable {
  final List<FlSpot> weeklySessionsSpots;
  final Map<int, int> gradeDistribution;
  final double surahCompletionPercentage;
  final List<String> completedSurahs;

  const ChartData({
    this.weeklySessionsSpots = const [],
    this.gradeDistribution = const {},
    this.surahCompletionPercentage = 0,
    this.completedSurahs = const [],
  });

  factory ChartData.fromGrades(List<ProgressGrade> grades) {
    if (grades.isEmpty) {
      return const ChartData();
    }

    // Calculate weekly sessions (last 7 weeks)
    final weeklySessions = _calculateWeeklySessions(grades);

    // Calculate grade distribution
    final gradeDistribution = _calculateGradeDistribution(grades);

    // Calculate surah completion (unique surahs / 114 total)
    final surahs = _extractUniqueSurahs(grades);
    final surahCompletion = surahs.length / 114;

    return ChartData(
      weeklySessionsSpots: weeklySessions,
      gradeDistribution: gradeDistribution,
      surahCompletionPercentage: surahCompletion,
      completedSurahs: surahs.toList(),
    );
  }

  static List<FlSpot> _calculateWeeklySessions(List<ProgressGrade> grades) {
    final now = DateTime.now();
    final Map<int, int> weeklyCounts = {};

    for (int i = 6; i >= 0; i--) {
      weeklyCounts[i] = 0;
    }

    for (final grade in grades) {
      final daysAgo = now.difference(grade.createdAt).inDays;
      final weekIndex = 6 - (daysAgo ~/ 7);
      if (weekIndex >= 0 && weekIndex <= 6) {
        weeklyCounts[weekIndex] = (weeklyCounts[weekIndex] ?? 0) + 1;
      }
    }

    return weeklyCounts.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();
  }

  static Map<int, int> _calculateGradeDistribution(List<ProgressGrade> grades) {
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final grade in grades) {
      distribution[grade.grade] = (distribution[grade.grade] ?? 0) + 1;
    }
    return distribution;
  }

  static Set<String> _extractUniqueSurahs(List<ProgressGrade> grades) {
    final surahs = <String>{};
    for (final grade in grades) {
      if (grade.surahs != null) {
        surahs.addAll(grade.surahs!);
      }
    }
    return surahs;
  }

  @override
  List<Object?> get props => [
        weeklySessionsSpots,
        gradeDistribution,
        surahCompletionPercentage,
        completedSurahs,
      ];
}

class GradingState extends Equatable {
  final GradingStatus status;
  final List<ProgressGrade>? grades;
  final ProgressGrade? selectedGrade;
  final ProgressSummary? progressSummary;
  final ProgressTimeline? progressTimeline;
  final List<StudentProgress>? classProgress;
  final ChartData? chartData;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const GradingState({
    required this.status,
    this.grades,
    this.selectedGrade,
    this.progressSummary,
    this.progressTimeline,
    this.classProgress,
    this.chartData,
    this.errorMessage,
    this.lastUpdated,
  });

  factory GradingState.initial() => const GradingState(
        status: GradingStatus.initial,
      );

  GradingState copyWith({
    GradingStatus? status,
    List<ProgressGrade>? grades,
    ProgressGrade? selectedGrade,
    ProgressSummary? progressSummary,
    ProgressTimeline? progressTimeline,
    List<StudentProgress>? classProgress,
    ChartData? chartData,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return GradingState(
      status: status ?? this.status,
      grades: grades ?? this.grades,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      progressSummary: progressSummary ?? this.progressSummary,
      progressTimeline: progressTimeline ?? this.progressTimeline,
      classProgress: classProgress ?? this.classProgress,
      chartData: chartData ?? this.chartData,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        grades,
        selectedGrade,
        progressSummary,
        progressTimeline,
        classProgress,
        chartData,
        errorMessage,
        lastUpdated,
      ];
}
