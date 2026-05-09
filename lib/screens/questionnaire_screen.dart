import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';
import '../models/attribute.dart';
import '../services/assessment_service.dart';
import '../services/auth_service.dart';
import '../widgets/attribute_icon.dart';
import '../widgets/rating_selector.dart';
import '../widgets/scripture_chip.dart';
import 'reflection_finish_screen.dart';

/// Paginated questionnaire — one attribute per page, all of its statements
/// stacked as rating selectors. The user can swipe forward/back, jump via the
/// chip rail at the top, and the draft persists between sessions.
///
/// Behaviour notes:
/// - Tapping a fresh rating auto-scrolls the next question into view.
/// - Changing an existing rating does NOT auto-scroll (user is editing).
/// - The active attribute chip in the rail auto-centers when the page changes.
/// - Long-press on the app bar progress count opens the hidden dev fill.
class QuestionnaireScreen extends StatefulWidget {
  final AssessmentService assessments;
  final AuthService auth;
  const QuestionnaireScreen({
    super.key,
    required this.assessments,
    required this.auth,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    final draft = widget.assessments.startOrResumeDraft();
    _index = _firstIncompletePage(draft);
    _controller = PageController(initialPage: _index);
  }

  int _firstIncompletePage(Assessment draft) {
    for (var i = 0; i < kAttributes.length; i++) {
      final attr = kAttributes[i];
      final answered =
          attr.questions.where((q) => draft.ratings.containsKey(q.id)).length;
      if (answered < attr.questions.length) return i;
    }
    return kAttributes.length - 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) {
    setState(() => _index = page);
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _confirmDiscard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard this reflection?'),
        content: const Text(
            'Your in-progress answers will be removed. You can always begin again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await widget.assessments.discardDraft();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _devFillDraft() async {
    HapticFeedback.mediumImpact();
    await widget.assessments.fillCurrentDraftRandomly();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filled draft with random ratings (dev mode).'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.assessments,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        // Treat the assessment service as authoritative. initState already
        // called startOrResumeDraft() once. If the draft is null here, the
        // user just finished — finishDraft() cleared it and a notifyListeners
        // forced this rebuild while the screen is still in the navigation
        // stack waiting to be popped. Render nothing for that single frame
        // rather than rehydrating an empty draft (which the home screen
        // would then surface as a stale "Continue where you left off" card).
        final draft = widget.assessments.draft;
        if (draft == null) return const SizedBox.shrink();
        final progress = draft.answeredCount / draft.totalQuestions;

        // Back is always allowed — the draft auto-saves on every tap, so
        // exiting mid-reflection is safe and the home screen offers Resume.
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: _devFillDraft,
                child: Text(
                  '${draft.answeredCount} / ${draft.totalQuestions}',
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Discard',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDiscard,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: scheme.outline.withValues(alpha: 0.3),
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                _AttributePager(
                  current: _index,
                  draft: draft,
                  onSelect: _go,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: kAttributes.length,
                    itemBuilder: (context, i) {
                      final a = kAttributes[i];
                      return _AttributePage(
                        // Stable per-attribute key so each page keeps its own
                        // ScrollController + GlobalKeys across rebuilds.
                        key: ValueKey('attr-page-${a.id}'),
                        attribute: a,
                        draft: draft,
                        audience: widget.assessments.audience,
                        onRate: (qid, rating) {
                          widget.assessments.setRating(qid, rating);
                        },
                        onSectionCompleted: () {
                          if (!mounted) return;
                          if (i == kAttributes.length - 1) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReflectionFinishScreen(
                                  assessments: widget.assessments,
                                  auth: widget.auth,
                                ),
                              ),
                            );
                          } else {
                            _go(i + 1);
                          }
                        },
                      );
                    },
                  ),
                ),
                _BottomNav(
                  index: _index,
                  total: kAttributes.length,
                  isComplete: draft.isComplete,
                  attributeAnswered: kAttributes[_index]
                      .questions
                      .every((q) => draft.ratings.containsKey(q.id)),
                  onPrev: _index == 0 ? null : () => _go(_index - 1),
                  onNext: _index == kAttributes.length - 1
                      ? null
                      : () => _go(_index + 1),
                  onFinish: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReflectionFinishScreen(
                          assessments: widget.assessments,
                          auth: widget.auth,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
      },
    );
  }
}

class _AttributePager extends StatefulWidget {
  final int current;
  final Assessment draft;
  final ValueChanged<int> onSelect;
  const _AttributePager({
    required this.current,
    required this.draft,
    required this.onSelect,
  });

  @override
  State<_AttributePager> createState() => _AttributePagerState();
}

class _AttributePagerState extends State<_AttributePager> {
  final ScrollController _controller = ScrollController();
  late final List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _chipKeys = List.generate(kAttributes.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCurrentVisible(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant _AttributePager old) {
    super.didUpdateWidget(old);
    if (old.current != widget.current) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureCurrentVisible(animate: true);
      });
    }
  }

  void _ensureCurrentVisible({required bool animate}) {
    final ctx = _chipKeys[widget.current].currentContext;
    if (ctx == null || !mounted) return;
    Scrollable.ensureVisible(
      ctx,
      duration:
          animate ? const Duration(milliseconds: 320) : Duration.zero,
      curve: Curves.easeInOutCubic,
      alignment: 0.5, // center the chip horizontally
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: kAttributes.length,
        itemBuilder: (context, i) {
          final a = kAttributes[i];
          final color = Color(a.color);
          final answered = a.questions
              .where((q) => widget.draft.ratings.containsKey(q.id))
              .length;
          final done = answered == a.questions.length;
          final selected = i == widget.current;
          return Padding(
            key: _chipKeys[i],
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => widget.onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.18)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: selected
                        ? color
                        : scheme.outline.withValues(alpha: 0.4),
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle
                          : iconForAttribute(a.id),
                      size: 16,
                      color: done
                          ? color
                          : (selected ? color : scheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      a.shortName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: selected
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttributePage extends StatefulWidget {
  final Attribute attribute;
  final Assessment draft;
  final Audience audience;
  final void Function(String qid, int rating) onRate;
  /// Fires when a fresh rating completes the last unanswered question of
  /// this attribute. Parent decides whether that means advancing to the
  /// next page or pushing the finish screen.
  final VoidCallback onSectionCompleted;

  const _AttributePage({
    super.key,
    required this.attribute,
    required this.draft,
    required this.audience,
    required this.onRate,
    required this.onSectionCompleted,
  });

  @override
  State<_AttributePage> createState() => _AttributePageState();
}

class _AttributePageState extends State<_AttributePage> {
  late List<GlobalKey> _questionKeys;

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
  }

  @override
  void didUpdateWidget(covariant _AttributePage old) {
    super.didUpdateWidget(old);
    if (old.attribute.id != widget.attribute.id ||
        old.attribute.questions.length != widget.attribute.questions.length) {
      _rebuildKeys();
    }
  }

  void _rebuildKeys() {
    _questionKeys = List.generate(
      widget.attribute.questions.length,
      (_) => GlobalKey(),
    );
  }

  void _handleRate(int index, String qid, int rating) {
    final wasUnanswered = !widget.draft.ratings.containsKey(qid);
    widget.onRate(qid, rating);
    // Only react when this is a fresh answer — editing an existing rating
    // shouldn't whisk the user away.
    if (!wasUnanswered) return;

    // widget.draft is the snapshot from before this rate (the parent has
    // not rebuilt yet). If exactly one question was unanswered before this
    // tap and it was this one, this tap just completed the section.
    final unansweredBefore = widget.attribute.questions
        .where((q) => !widget.draft.ratings.containsKey(q.id))
        .length;
    if (unansweredBefore == 1) {
      // Long enough for the rating animation to land + a brief beat for the
      // user to register "yes, that's what I meant" before we slide forward.
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        widget.onSectionCompleted();
      });
      return;
    }

    // Otherwise, scroll the next question within this attribute into view.
    final next = index + 1;
    if (next >= widget.attribute.questions.length) return;
    // Brief delay so the rating animation lands and the user sees it before
    // we begin scrolling.
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      final ctx = _questionKeys[next].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = Color(widget.attribute.color);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            AttributeAvatar(id: widget.attribute.id, color: color, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.attribute.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.attribute.questions.length} reflections',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Text(
            widget.attribute.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...widget.attribute.questions.asMap().entries.map((entry) {
          final i = entry.key;
          final q = entry.value;
          final value = widget.draft.ratings[q.id];
          final showingAlternate =
              widget.audience == Audience.member && q.lifeText != null;
          final renderedText = showingAlternate ? q.lifeText! : q.text;
          return Padding(
            key: _questionKeys[i],
            padding: const EdgeInsets.only(bottom: 18),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${i + 1}',
                            style:
                                theme.textTheme.labelMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                renderedText,
                                style:
                                    theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (showingAlternate) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Adapted from Preach My Gospel for non-mission settings.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant
                                        .withValues(alpha: 0.85),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (q.scriptures.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ScriptureChipRow(
                        scriptures: q.scriptures,
                        color: color,
                      ),
                    ],
                    const SizedBox(height: 14),
                    RatingSelector(
                      value: value,
                      accent: color,
                      onChanged: (v) => _handleRate(i, q.id, v),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final int total;
  final bool isComplete;
  final bool attributeAnswered;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onFinish;

  const _BottomNav({
    required this.index,
    required this.total,
    required this.isComplete,
    required this.attributeAnswered,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lastPage = index == total - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(color: scheme.outline.withValues(alpha: 0.4)),
          ),
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: onPrev,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: lastPage
                  ? FilledButton.icon(
                      onPressed: isComplete ? onFinish : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        isComplete
                            ? 'Continue'
                            : 'Answer every reflection',
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

