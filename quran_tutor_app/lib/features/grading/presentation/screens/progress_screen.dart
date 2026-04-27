import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/grading_bloc.dart';
import '../bloc/grading_event.dart';
import '../bloc/grading_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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
            return Center(child: Text('خطأ: ${state.errorMessage}'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sessions per week chart
                _buildSectionTitle('الجلسات الأسبوعية'),
                _buildLineChart(),
                const SizedBox(height: 24),

                // Grade distribution chart
                _buildSectionTitle('توزيع التقييمات'),
                _buildBarChart(),
                const SizedBox(height: 24),

                // Surah completion progress
                _buildSectionTitle('تقدم حفظ السور'),
                _buildRadialChart(),
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

  Widget _buildLineChart() {
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
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 4),
                FlSpot(2, 3),
                FlSpot(3, 5),
                FlSpot(4, 4),
                FlSpot(5, 6),
                FlSpot(6, 5),
              ],
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

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(toY: 8, color: Colors.red),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 12, color: Colors.orange),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 15, color: Colors.yellow),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 10, color: Colors.lightGreen),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(toY: 18, color: Colors.green),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = ['ضعيف', 'مقبول', 'جيد', 'جيد جدا', 'ممتاز'];
                  if (value >= 0 && value < labels.length) {
                    return Text(labels[value.toInt()]);
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

  Widget _buildRadialChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 30,
              title: '30%',
              color: Colors.green,
              radius: 80,
            ),
            PieChartSectionData(
              value: 70,
              title: '70%',
              color: Colors.grey.shade300,
              radius: 80,
            ),
          ],
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
