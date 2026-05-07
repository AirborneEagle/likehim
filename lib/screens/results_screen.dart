import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';
import '../models/attribute.dart';
import '../services/assessment_service.dart';
import '../services/auth_service.dart';
import '../widgets/attribute_icon.dart';
import '../widgets/attribute_radar_chart.dart';
import 'attribute_detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Assessment assessment;
  final AssessmentService assessments;
  final AuthService auth;
  final bool isJustCompleted;

  const ResultsScreen({
    super.key,
    required this.assessment,
    required this.assessments,
    required this.auth,
    this.isJustCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat.yMMMMd().add_jm();

    final sortedAttrs = List<Attribute>.from(kAttributes)
      ..sort((a, b) {
        final sa = assessment.attributeScore(a.id) ?? 0;
        final sb = assessment.attributeScore(b.id) ?? 0;
        return sb.compareTo(sa);
      });

    final highest = sortedAttrs.first;
    final lowest = sortedAttrs.last;

    final history = assessments.assessments;
    final myIndex = history.indexWhere((a) => a.id == assessment.id);
    final previous =
        (myIndex >= 0 && myIndex + 1 < history.length) ? history[myIndex + 1] : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(isJustCompleted ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (isJustCompleted) {
              Navigator.of(context).popUntil((r) => r.isFirst);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(isJustCompleted ? 'Reflection saved' : 'Snapshot'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (isJustCompleted) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: scheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Reflection saved. Take a moment with what you noticed.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(fmt.format(assessment.takenAt),
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          Text('Where you are right now',
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          Center(
            child: AttributeRadarChart(
              assessment: assessment,
              compareTo: previous,
              size: 320,
            ),
          ),
          if (previous != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Legend(color: scheme.primary, label: 'This reflection'),
                  _Legend(color: scheme.tertiary, label: 'Previous'),
                ],
              ),
            ),
          ],
          if ((assessment.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.secondary.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_quote_outlined,
                          size: 16, color: scheme.secondary),
                      const SizedBox(width: 6),
                      Text('What you noticed',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.secondary,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    assessment.note!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _HighlightCard(
                  label: 'A place of strength',
                  attribute: highest,
                  score: assessment.attributeScore(highest.id) ?? 0,
                  icon: Icons.star_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HighlightCard(
                  label: 'An invitation to grow',
                  attribute: lowest,
                  score: assessment.attributeScore(lowest.id) ?? 0,
                  icon: Icons.local_florist_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('All attributes', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...sortedAttrs.map((a) {
            final score = assessment.attributeScore(a.id) ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AttributeDetailScreen(
                        attribute: a,
                        assessments: assessments,
                      ),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        AttributeAvatar(
                            id: a.id, color: Color(a.color), size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name,
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (score / 5).clamp(0, 1),
                                  minHeight: 6,
                                  backgroundColor: Color(a.color)
                                      .withValues(alpha: 0.14),
                                  color: Color(a.color),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(score.toStringAsFixed(1),
                            style:
                                theme.textTheme.titleLarge?.copyWith(
                              color: Color(a.color),
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (isJustCompleted) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to home'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final Attribute attribute;
  final double score;
  final IconData icon;
  const _HighlightCard({
    required this.label,
    required this.attribute,
    required this.score,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = Color(attribute.color);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 10),
            AttributeAvatar(id: attribute.id, color: color, size: 32),
            const SizedBox(height: 10),
            Text(attribute.shortName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text('${score.toStringAsFixed(1)} / 5',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
