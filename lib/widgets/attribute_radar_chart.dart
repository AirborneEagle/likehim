import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';

/// Radar chart showing one assessment's score per attribute on a fixed
/// 1–5 scale.
///
/// The scale is pinned: outermost ring = 5.0 ("Always"), innermost point
/// = 1.0 ("Never"). Every reflection plots against the same backdrop, so
/// a 4.0 always sits 75% of the way out — never dragged to the centre by
/// a slightly-better cluster of other attributes.
///
/// fl_chart auto-scales to the largest value seen across all data sets,
/// so we pin the upper bound with an invisible ceiling set at 4.0 (post-
/// transform). Plotted values map raw 1..5 → 0..4 so the inner-most point
/// of the polygon corresponds to a rating of 1.
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

  /// Map a raw 1..5 score (or null for an unrated attribute) onto the
  /// chart's 0..4 plotted extent. Null/missing → innermost ring (1.0).
  static double _plotted(double? raw) {
    final v = (raw ?? 1.0).clamp(1.0, 5.0);
    return v - 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final currentColor = scheme.primary;
    final previousColor = scheme.tertiary;

    final entries = <RadarEntry>[
      for (final a in kAttributes)
        RadarEntry(value: _plotted(assessment.attributeScore(a.id))),
    ];

    final dataSets = <RadarDataSet>[];

    // Invisible ceiling: pins the auto-scale upper bound to 5.0 raw
    // (= 4.0 plotted), regardless of how the actual reflection scored.
    // Drawn first so it's underneath everything.
    dataSets.add(
      RadarDataSet(
        dataEntries: List<RadarEntry>.filled(
          kAttributes.length,
          const RadarEntry(value: 4.0),
        ),
        fillColor: Colors.transparent,
        borderColor: Colors.transparent,
        borderWidth: 0,
        entryRadius: 0,
      ),
    );

    if (compareTo != null) {
      final cmp = <RadarEntry>[
        for (final a in kAttributes)
          RadarEntry(value: _plotted(compareTo!.attributeScore(a.id))),
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
