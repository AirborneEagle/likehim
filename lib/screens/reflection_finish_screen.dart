import 'package:flutter/material.dart';

import '../data/claa_data.dart';
import '../services/assessment_service.dart';
import '../services/auth_service.dart';
import '../widgets/attribute_icon.dart';
import '../widgets/attribute_radar_chart.dart';
import 'results_screen.dart';

/// Shown after the user has answered every statement. Two devotional choices
/// before the reflection is saved:
///   1. A short note ("anything you noticed?") — optional, private, never shown.
///   2. A focus attribute ("sit with one this week") — PMG explicitly invites
///      this; we surface it on the home screen until the next reflection.
class ReflectionFinishScreen extends StatefulWidget {
  final AssessmentService assessments;
  final AuthService auth;
  const ReflectionFinishScreen({
    super.key,
    required this.assessments,
    required this.auth,
  });

  @override
  State<ReflectionFinishScreen> createState() => _ReflectionFinishScreenState();
}

class _ReflectionFinishScreenState extends State<ReflectionFinishScreen> {
  final _noteCtrl = TextEditingController();
  String? _selectedFocusId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl.text = widget.assessments.draft?.note ?? '';
    // Pre-fill with the user's existing focus if there is one.
    _selectedFocusId = widget.assessments.focusAttributeId;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final note = _noteCtrl.text.trim();
      await widget.assessments.setNote(note.isEmpty ? null : note);
      if (_selectedFocusId !=
          widget.assessments.focusAttributeId) {
        await widget.assessments.setFocus(_selectedFocusId);
      }
      final saved = await widget.assessments.finishDraft();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            assessment: saved,
            assessments: widget.assessments,
            auth: widget.auth,
            isJustCompleted: true,
          ),
        ),
        // Keep only the home screen underneath.
        (route) => route.isFirst,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t save: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final draft = widget.assessments.draft;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Almost done'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (draft != null) ...[
            Center(
              child: AttributeRadarChart(
                assessment: draft,
                size: 240,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Where you are right now.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text('Anything you noticed?',
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Optional. For your eyes only.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText:
                  'A feeling, a name, an experience, a verse… whatever you want to remember about this moment.',
            ),
          ),
          const SizedBox(height: 32),
          Text('Sit with one this week',
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Pick an attribute to keep close — in thought, scripture, and small acts. You can change it anytime.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in kAttributes)
                _FocusChoice(
                  id: a.id,
                  name: a.shortName,
                  color: Color(a.color),
                  selected: _selectedFocusId == a.id,
                  onTap: () {
                    setState(() {
                      _selectedFocusId =
                          _selectedFocusId == a.id ? null : a.id;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedFocusId != null)
            Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => _selectedFocusId = null),
                child: const Text('Skip — none for now'),
              ),
            ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Save reflection'),
          ),
        ],
      ),
    );
  }
}

class _FocusChoice extends StatelessWidget {
  final String id;
  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FocusChoice({
    required this.id,
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? color : scheme.outline.withValues(alpha: 0.5),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AttributeAvatar(id: id, color: color, size: 28),
            const SizedBox(width: 8),
            Text(
              name,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
