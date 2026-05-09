import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';
import '../models/attribute.dart';
import '../services/auth_service.dart';
import '../services/assessment_service.dart';
import '../widgets/attribute_icon.dart';
import '../widgets/attribute_radar_chart.dart';
import 'attribute_detail_screen.dart';
import 'history_screen.dart';
import 'questionnaire_screen.dart';
import 'reflection_intro_screen.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService auth;
  final AssessmentService assessments;

  const HomeScreen({
    super.key,
    required this.auth,
    required this.assessments,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([auth, assessments]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final user = auth.currentUser;
        final latest = assessments.latestComplete;
        final draft = assessments.draft;
        final history = assessments.assessments;

        final greeting = _greetingFor(DateTime.now(), user?.displayName);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 0,
                toolbarHeight: 64,
                backgroundColor: theme.scaffoldBackgroundColor,
                title: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () => _showDevMenu(context),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/icon/icon_master.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Like Him', style: theme.textTheme.titleLarge),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          auth: auth,
                          assessments: assessments,
                        ),
                      ));
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      greeting,
                      style: theme.textTheme.displaySmall?.copyWith(
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latest == null
                          ? 'A quiet companion for becoming\nmore like the Savior.'
                          : 'A quiet moment with the One\nyou\'re becoming like.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (assessments.focusAttributeId != null) ...[
                      _FocusCard(
                        attribute: kAttributes.firstWhere(
                          (a) => a.id == assessments.focusAttributeId,
                          orElse: () => kAttributes.first,
                        ),
                        setAt: assessments.focusSetAt,
                        onOpen: (a) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AttributeDetailScreen(
                              attribute: a,
                              assessments: assessments,
                            ),
                          ));
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (draft != null) _ResumeDraftCard(
                      draft: draft,
                      onResume: () => _openQuestionnaire(context, resume: true),
                      onDiscard: () async {
                        await assessments.discardDraft();
                      },
                    ),
                    if (draft != null) const SizedBox(height: 16),
                    _PrimaryActionCard(
                      hasLatest: latest != null,
                      onStart: () => _openQuestionnaire(context),
                    ),
                    if (latest != null) ...[
                      const SizedBox(height: 28),
                      _LatestReflection(
                        latest: latest,
                        previous: history.length >= 2 ? history[1] : null,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ResultsScreen(
                              assessment: latest,
                              assessments: assessments,
                              auth: auth,
                              isJustCompleted: false,
                            ),
                          ));
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text('Attributes',
                            style: theme.textTheme.headlineSmall),
                        const Spacer(),
                        if (history.length >= 2)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => HistoryScreen(
                                  assessments: assessments,
                                ),
                              ));
                            },
                            icon: const Icon(Icons.timeline, size: 18),
                            label: const Text('History'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...kAttributes.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AttributeRow(
                            attribute: a,
                            latest: latest?.attributeScore(a.id),
                            history: history,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AttributeDetailScreen(
                                  attribute: a,
                                  assessments: assessments,
                                ),
                              ));
                            },
                          ),
                        )),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Hidden long-press menu on the brand mark — for testing only.
  void _showDevMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.tertiary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DEV',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.tertiary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Developer tools',
                        style: textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 2, top: 4),
                  child: Text(
                    'Hidden behind a long-press on the brand mark. Not visible to end users.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shuffle),
                  title: const Text('Auto-fill current draft'),
                  subtitle: const Text(
                      'Fills every question with a random rating'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await assessments.fillCurrentDraftRandomly();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Draft auto-filled with random ratings.'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timeline),
                  title: const Text('Seed historical reflections'),
                  subtitle: const Text(
                      '8 past assessments, ~14 days apart, gentle upward trend'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await assessments.seedRandomHistory(count: 8);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Seeded 8 historical reflections. Charts should populate.'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.center_focus_strong_outlined),
                  title: const Text('Set a random focus attribute'),
                  subtitle: const Text(
                      'Pick one at random to populate the focus card'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final rand = math.Random();
                    final pick =
                        kAttributes[rand.nextInt(kAttributes.length)];
                    await assessments.setFocus(pick.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Focus set to ${pick.name}.'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_forever, color: scheme.error),
                  title: Text('Delete all my reflections',
                      style: TextStyle(color: scheme.error)),
                  subtitle: const Text(
                      'Wipes saved snapshots and any in-flight draft'),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: ctx,
                      builder: (d) => AlertDialog(
                        title: const Text('Delete everything?'),
                        content: const Text(
                            'This wipes every saved reflection and the current draft for this user.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(d).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    Navigator.of(ctx).pop();
                    await assessments.clearAllForTesting();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All reflections deleted.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openQuestionnaire(BuildContext context, {bool resume = false}) async {
    if (!resume) {
      // Pause for a prayerful moment before starting fresh.
      final ready = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const ReflectionIntroScreen()),
      );
      if (ready != true || !context.mounted) return;
    }
    // The questionnaire pushes the finish screen, which pushes the
    // results screen and clears intermediate routes — we don't await a
    // returned assessment here.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionnaireScreen(
          assessments: assessments,
          auth: auth,
        ),
      ),
    );
  }
}

String _greetingFor(DateTime now, String? name) {
  final h = now.hour;
  String base;
  if (h < 5) {
    base = 'Hello';
  } else if (h < 12) {
    base = 'Good morning';
  } else if (h < 17) {
    base = 'Good afternoon';
  } else if (h < 21) {
    base = 'Good evening';
  } else {
    base = 'Peace, friend';
  }
  if (name != null && name.isNotEmpty) {
    return '$base,\n$name.';
  }
  return '$base.';
}

class _ResumeDraftCard extends StatelessWidget {
  final Assessment draft;
  final VoidCallback onResume;
  final VoidCallback onDiscard;
  const _ResumeDraftCard({
    required this.draft,
    required this.onResume,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pct = (draft.answeredCount / draft.totalQuestions);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.secondary.withValues(alpha: 0.4)),
      ),
      color: scheme.secondaryContainer.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark_outline, color: scheme.secondary),
                const SizedBox(width: 8),
                Text('Continue where you left off',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${draft.answeredCount} of ${draft.totalQuestions} answered',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor:
                    scheme.surface.withValues(alpha: 0.6),
                color: scheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onDiscard,
                  child: const Text('Discard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final bool hasLatest;
  final VoidCallback onStart;
  const _PrimaryActionCard(
      {required this.hasLatest, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Warm "sunrise" gradient — terracotta deepening toward warm amber-brown.
    // Sits warmer than the cool primary blue; supports white text comfortably.
    return Material(
      color: scheme.tertiary,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                scheme.secondary, // warm gold (top-left)
                scheme.tertiary, // terracotta (mid)
                Color.lerp(scheme.tertiary, Colors.black, 0.18)!, // deeper
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLatest ? 'Reflect again' : 'Begin reflecting',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'About 8–10 quiet minutes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestReflection extends StatelessWidget {
  final Assessment latest;
  final Assessment? previous;
  final VoidCallback onTap;
  const _LatestReflection({
    required this.latest,
    required this.previous,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat.yMMMMd();
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Where you are right now',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      )),
                  const Spacer(),
                  Text(fmt.format(latest.takenAt),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: AttributeRadarChart(
                  assessment: latest,
                  compareTo: previous,
                  size: 240,
                ),
              ),
              if (previous != null) ...[
                const SizedBox(height: 4),
                Center(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      _LegendDot(color: scheme.primary, label: 'This reflection'),
                      _LegendDot(color: scheme.tertiary, label: 'Previous'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FocusCard extends StatelessWidget {
  final Attribute attribute;
  final DateTime? setAt;
  final void Function(Attribute) onOpen;

  const _FocusCard({
    required this.attribute,
    required this.setAt,
    required this.onOpen,
  });

  String _agoLabel(DateTime? setAt) {
    if (setAt == null) return '';
    final diff = DateTime.now().difference(setAt);
    if (diff.inHours < 1) return 'just now';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'set $h hour${h == 1 ? '' : 's'} ago';
    }
    final days = diff.inDays;
    if (days < 7) return 'set $days day${days == 1 ? '' : 's'} ago';
    final weeks = (days / 7).floor();
    return 'set $weeks week${weeks == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = Color(attribute.color);
    // Take the first sentence of the description as a brief inline reading.
    final firstLine = attribute.description.split(RegExp(r'(?<=\.) ')).first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOpen(attribute),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'YOUR FOCUS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (setAt != null)
                    Text(_agoLabel(setAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  AttributeAvatar(id: attribute.id, color: color, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      attribute.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                firstLine,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.82),
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final Attribute attribute;
  final double? latest;
  final List<Assessment> history;
  final VoidCallback onTap;

  const _AttributeRow({
    required this.attribute,
    required this.latest,
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = Color(attribute.color);
    final scoreLabel = latest == null ? '—' : latest!.toStringAsFixed(1);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              AttributeAvatar(id: attribute.id, color: color, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(attribute.name,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${attribute.questions.length} reflections',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                height: 28,
                child: _Sparkline(
                  values: history.reversed
                      .map((a) => a.attributeScore(attribute.id))
                      .whereType<double>()
                      .toList(),
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                scoreLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: latest == null
                      ? scheme.onSurfaceVariant
                      : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  const _Sparkline({required this.values, required this.color});
  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();
    return CustomPaint(
      painter: _SparklinePainter(values, color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparklinePainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    const minV = 1.0;
    const maxV = 5.0;
    final dx = size.width / math.max(values.length - 1, 1);
    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * dx;
      final v = values[i].clamp(minV, maxV);
      final y = size.height - ((v - minV) / (maxV - minV)) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}
