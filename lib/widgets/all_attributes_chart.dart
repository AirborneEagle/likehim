import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';

/// Single line chart with one trend line per attribute. Tapping a legend
/// chip spotlights that attribute and dims the rest; tapping again clears.
class AllAttributesChart extends StatefulWidget {
  final List<Assessment> assessments; // chronological, oldest first
  const AllAttributesChart({super.key, required this.assessments});

  @override
  State<AllAttributesChart> createState() => _AllAttributesChartState();
}

class _AllAttributesChartState extends State<AllAttributesChart> {
  String? _spotlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final assessments = widget.assessments;

    if (assessments.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Take a few reflections to see all attributes side by side.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final fmt = DateFormat.MMMd();
    final hasMultiple = assessments.length >= 2;
    final maxX = hasMultiple ? (assessments.length - 1).toDouble() : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 5,
              minX: 0,
              maxX: maxX,
              clipData: const FlClipData.all(),
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
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
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
                        : ((assessments.length - 1) / 4)
                            .ceilToDouble()
                            .clamp(1, 999),
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
                for (final a in kAttributes)
                  _lineFor(a.id, Color(a.color), assessments, hasMultiple),
              ],
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touched) {
                    if (touched.isEmpty) return const [];
                    final lines = <LineTooltipItem>[];
                    for (final s in touched) {
                      final attr = kAttributes[s.barIndex];
                      lines.add(
                        LineTooltipItem(
                          '${attr.shortName}  ${s.y.toStringAsFixed(1)}',
                          theme.textTheme.bodySmall!.copyWith(
                            color: Color(attr.color),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return lines;
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in kAttributes)
              _LegendChip(
                label: a.shortName,
                color: Color(a.color),
                selected: _spotlight == a.id,
                anySelected: _spotlight != null,
                onTap: () {
                  setState(() {
                    _spotlight = _spotlight == a.id ? null : a.id;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  LineChartBarData _lineFor(
    String attributeId,
    Color color,
    List<Assessment> assessments,
    bool hasMultiple,
  ) {
    final spots = <FlSpot>[];
    for (var i = 0; i < assessments.length; i++) {
      final s = assessments[i].attributeScore(attributeId);
      if (s != null) spots.add(FlSpot(i.toDouble(), s));
    }
    final spot = _spotlight;
    final dimmed = spot != null && spot != attributeId;
    final highlighted = spot == attributeId;

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.28,
      color: dimmed
          ? color.withValues(alpha: 0.10)
          : color.withValues(alpha: highlighted ? 1.0 : 0.85),
      barWidth: highlighted ? 3.2 : 2.0,
      dotData: FlDotData(
        show: hasMultiple ? highlighted : true,
        getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
          radius: highlighted ? 3.5 : 2.5,
          color: color,
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(show: false),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final bool anySelected;
  final VoidCallback onTap;

  const _LegendChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.anySelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dim = anySelected && !selected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? color
                : scheme.outline.withValues(alpha: 0.5),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dim ? color.withValues(alpha: 0.35) : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: dim
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
                    : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
