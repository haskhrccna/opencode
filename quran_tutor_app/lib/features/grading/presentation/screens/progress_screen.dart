import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/grading_bloc.dart';
import '../bloc/grading_event.dart';
import '../bloc/grading_state.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading grades when screen opens
    context.read<GradingBloc>().add(const LoadGrades());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقدمي'),
      ),
      body: BlocBuilder<GradingBloc, GradingState>(
        builder: (context, state) {
          if (state.status == GradingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == GradingStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطأ: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GradingBloc>().add(const LoadGrades());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final chartData = state.chartData;
          final hasData = chartData != null &&
              (chartData.weeklySessionsSpots.isNotEmpty ||
                  chartData.gradeDistribution.isNotEmpty);

          if (!hasData) {
            return const Center(
              child: Text(
                'لا توجد بيانات كافية لعرض التقدم',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sessions per week chart
                _buildSectionTitle('الجلسات الأسبوعية'),
                _buildLineChart(chartData!.weeklySessionsSpots),
                const SizedBox(height: 24),

                // Grade distribution chart
                _buildSectionTitle('توزيع التقييمات'),
                _buildBarChart(chartData.gradeDistribution),
                const SizedBox(height: 24),

                // Surah completion progress
                _buildSectionTitle('تقدم حفظ السور'),
                _buildRadialChart(
                  chartData.surahCompletionPercentage,
                  chartData.completedSurahs,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('لا توجد بيانات')),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final weekLabels = [
                    'أسبوع 1',
                    'أسبوع 2',
                    'أسبوع 3',
                    'أسبوع 4',
                    'أسبوع 5',
                    'أسبوع 6',
                    'الحالي'
                  ];
                  if (value >= 0 && value < weekLabels.length) {
                    return Text(
                      weekLabels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> distribution) {
    if (distribution.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('لا توجد بيانات')),
      );
    }

    final maxCount = distribution.values.reduce((a, b) => a > b ? a : b);

    final barGroups = distribution.entries.map((entry) {
      final colors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.lightGreen,
        Colors.green,
      ];
      final color = entry.key >= 1 && entry.key <= 5
          ? colors[entry.key - 1]
          : Colors.grey;

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: color,
            width: 20,
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount + 1).toDouble(),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = {
                    1: 'ضعيف',
                    2: 'مقبول',
                    3: 'جيد',
                    4: 'جيد جدا',
                    5: 'ممتاز',
                  };
                  final label = labels[value.toInt()];
                  if (label != null) {
                    return Text(
                      label,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadialChart(double percentage, List<String> completedSurahs) {
    final completedPercent = ((percentage * 100).clamp(0, 100) as double);
    final remainingPercent = (100 - completedPercent) as double;

    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: completedPercent,
                    title: '${completedPercent.toStringAsFixed(1)}%',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: remainingPercent,
                    title: '',
                    color: Colors.grey.shade300,
                    radius: 80,
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          if (completedSurahs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'السور المحفوظة: ${completedSurahs.take(5).join(", ")}${completedSurahs.length > 5 ? '...' : ''}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
