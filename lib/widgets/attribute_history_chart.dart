import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/assessment.dart';

/// Line chart of one attribute's score across multiple completed assessments.
///
/// The y-axis is pinned to the rating scale: 1 ("Never") at the bottom,
/// 5 ("Always") at the top. Auto-scaling would make a steady 4.0 look like
/// a flat line near the ceiling on one screen and near the floor on another
/// — the same deficit-framing-through-pixels problem the radar chart had.
class AttributeHistoryChart extends StatelessWidget {
  final List<Assessment> assessments; // chronological, oldest first
  final String attributeId;
  final Color color;

  const AttributeHistoryChart({
    super.key,
    required this.assessments,
    required this.attributeId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final spots = <FlSpot>[];
    for (var i = 0; i < assessments.length; i++) {
      final s = assessments[i].attributeScore(attributeId);
      if (s != null) spots.add(FlSpot(i.toDouble(), s));
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Take an assessment to start tracking.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final fmt = DateFormat.MMMd();
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 5,
          minX: 0,
          maxX: (assessments.length - 1).toDouble().clamp(0, double.infinity),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (v, _) {
                  if (v % 1 != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      v.toInt().toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: assessments.length <= 1
                    ? 1
                    : ((assessments.length - 1) / 4).ceilToDouble().clamp(1, 999),
                reservedSize: 26,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= assessments.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      fmt.format(assessments[i].takenAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.28,
              color: color,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: scheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (touched) => touched
                  .map(
                    (s) => LineTooltipItem(
                      s.y.toStringAsFixed(2),
                      theme.textTheme.bodyMedium!.copyWith(
                        color: scheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
