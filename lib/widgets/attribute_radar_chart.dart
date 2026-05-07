import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';

/// Radar chart showing one assessment's score per attribute (0–5 scale).
///
/// When [compareTo] is supplied, the previous reflection is drawn first
/// in warm terracotta so it reads as a secondary backdrop, then the current
/// reflection is drawn in luminous sky blue on top. The two are on opposite
/// sides of the colour wheel — maximum readable contrast at any size.
class AttributeRadarChart extends StatelessWidget {
  final Assessment assessment;
  final Assessment? compareTo;
  final double size;

  const AttributeRadarChart({
    super.key,
    required this.assessment,
    this.compareTo,
    this.size = 320,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final currentColor = scheme.primary;
    final previousColor = scheme.tertiary;

    final entries = <RadarEntry>[
      for (final a in kAttributes)
        RadarEntry(value: assessment.attributeScore(a.id) ?? 0),
    ];

    final dataSets = <RadarDataSet>[];

    if (compareTo != null) {
      final cmp = <RadarEntry>[
        for (final a in kAttributes)
          RadarEntry(value: compareTo!.attributeScore(a.id) ?? 0),
      ];
      dataSets.add(
        RadarDataSet(
          dataEntries: cmp,
          // Higher fill so the shape registers, but slightly translucent so
          // the current overlay still reads cleanly on top.
          fillColor: previousColor.withValues(alpha: 0.18),
          borderColor: previousColor,
          borderWidth: 2.2,
          // Bigger vertex markers help differentiate "previous" visually.
          entryRadius: 4.0,
        ),
      );
    }

    dataSets.add(
      RadarDataSet(
        dataEntries: entries,
        fillColor: currentColor.withValues(alpha: 0.28),
        borderColor: currentColor,
        borderWidth: 2.6,
        entryRadius: 3.5,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: RadarChart(
        RadarChartData(
          dataSets: dataSets,
          radarBackgroundColor: Colors.transparent,
          radarBorderData:
              BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
          gridBorderData: BorderSide(
            color: scheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
          tickBorderData: BorderSide(
            color: scheme.outline.withValues(alpha: 0.25),
            width: 1,
          ),
          titlePositionPercentageOffset: 0.18,
          getTitle: (i, _) => RadarChartTitle(
            text: kAttributes[i].shortName,
            angle: 0,
          ),
          titleTextStyle: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          tickCount: 5,
          ticksTextStyle: const TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
          radarShape: RadarShape.polygon,
        ),
      ),
    );
  }
}
