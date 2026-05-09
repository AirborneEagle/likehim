import 'package:flutter/material.dart';

import '../models/attribute.dart';
import '../services/assessment_service.dart';
import '../widgets/attribute_icon.dart';
import '../widgets/attribute_history_chart.dart';
import '../widgets/scripture_chip.dart';

class AttributeDetailScreen extends StatelessWidget {
  final Attribute attribute;
  final AssessmentService assessments;

  const AttributeDetailScreen({
    super.key,
    required this.attribute,
    required this.assessments,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: assessments,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final color = Color(attribute.color);
        final chronological = assessments.chronological();
        final completed =
            chronological.where((a) => a.isComplete).toList();
        final history = completed
            .map((a) => MapEntry(a, a.attributeScore(attribute.id)))
            .where((e) => e.value != null)
            .toList();
        final latestScore = history.isEmpty ? null : history.last.value;
        final firstScore = history.isEmpty ? null : history.first.value;
        final delta =
            (latestScore != null && firstScore != null && history.length > 1)
                ? latestScore - firstScore
                : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(attribute.shortName),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Row(
                children: [
                  AttributeAvatar(
                      id: attribute.id, color: color, size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(attribute.name,
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        if (latestScore != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(latestScore.toStringAsFixed(2),
                                  style:
                                      theme.textTheme.titleLarge?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(width: 4),
                              Text('latest',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  )),
                              if (delta != null) ...[
                                const SizedBox(width: 12),
                                _Delta(value: delta),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Text(
                  attribute.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: scheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FocusToggle(
                isFocus: assessments.focusAttributeId == attribute.id,
                color: color,
                onSet: () async {
                  await assessments.setFocus(attribute.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Focusing on ${attribute.shortName}.'),
                      ),
                    );
                  }
                },
                onClear: () async {
                  await assessments.setFocus(null);
                },
              ),
              const SizedBox(height: 24),
              Text('Over time', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                history.isEmpty
                    ? 'No reflections yet for this attribute.'
                    : '${history.length} reflection${history.length == 1 ? '' : 's'} recorded.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  child: AttributeHistoryChart(
                    assessments: completed,
                    attributeId: attribute.id,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Reflections', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...attribute.questions.asMap().entries.map((entry) {
                final i = entry.key;
                final q = entry.value;
                final per = history
                    .map((h) => MapEntry(
                        h.key.takenAt, h.key.ratings[q.id]?.toDouble()))
                    .where((e) => e.value != null)
                    .toList();
                final last = per.isEmpty ? null : per.last.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${i + 1}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  (assessments.audience == Audience.member &&
                                          q.lifeText != null)
                                      ? q.lifeText!
                                      : q.text,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(height: 1.4),
                                ),
                              ),
                              if (last != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  last.toStringAsFixed(0),
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (q.scriptures.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ScriptureChipRow(
                              scriptures: q.scriptures,
                              color: color,
                              compact: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _FocusToggle extends StatelessWidget {
  final bool isFocus;
  final Color color;
  final VoidCallback onSet;
  final VoidCallback onClear;

  const _FocusToggle({
    required this.isFocus,
    required this.color,
    required this.onSet,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (isFocus) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Row(
          children: [
            Icon(Icons.center_focus_strong_outlined, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This is your current focus.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text('Clear'),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onSet,
        icon: Icon(Icons.center_focus_strong_outlined, color: color),
        label: Text('Focus on this attribute',
            style: TextStyle(color: scheme.onSurface)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  final double value;
  const _Delta({required this.value});
  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final fg = positive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(positive ? Icons.trending_up : Icons.trending_down,
              size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            '${positive ? '+' : ''}${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
