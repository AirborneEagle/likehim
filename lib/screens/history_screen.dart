import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/claa_data.dart';
import '../services/assessment_service.dart';
import '../widgets/all_attributes_chart.dart';
import '../widgets/attribute_history_chart.dart';
import '../widgets/attribute_icon.dart';

class HistoryScreen extends StatelessWidget {
  final AssessmentService assessments;
  const HistoryScreen({super.key, required this.assessments});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: assessments,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final all =
            assessments.chronological().where((a) => a.isComplete).toList();

        if (all.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('History')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No reflections yet. Take an assessment to start tracking your journey.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('History')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                '${all.length} reflection${all.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text('Your journey, side by side',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'All attributes overlaid',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Text(
                          'Tap a chip to spotlight one line.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AllAttributesChart(assessments: all),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text('Each attribute, over time',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...kAttributes.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AttributeAvatar(
                                    id: a.id,
                                    color: Color(a.color),
                                    size: 32),
                                const SizedBox(width: 10),
                                Text(a.name,
                                    style: theme.textTheme.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AttributeHistoryChart(
                              assessments: all,
                              attributeId: a.id,
                              color: Color(a.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              Text('All reflections', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              ...all.reversed.map((s) {
                final fmt = DateFormat.yMMMMd().add_jm();
                final note = (s.note ?? '').trim();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(fmt.format(s.takenAt),
                          style: theme.textTheme.titleMedium),
                      subtitle: note.isEmpty
                          ? null
                          : Text(
                              note,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz),
                        onSelected: (v) async {
                          if (v == 'delete') {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title:
                                    const Text('Delete this reflection?'),
                                content: const Text(
                                    'This reflection will be removed permanently.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await assessments.deleteAssessment(s.id);
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
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
