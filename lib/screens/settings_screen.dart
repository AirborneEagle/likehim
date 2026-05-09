import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/assessment_service.dart';
import '../services/auth_service.dart';

// Re-export so the AnimatedBuilder rebuilds settings when reminder cadence
// changes — wrap the body in AnimatedBuilder against `widget.assessments`.

class SettingsScreen extends StatefulWidget {
  final AuthService auth;
  final AssessmentService assessments;
  const SettingsScreen({
    super.key,
    required this.auth,
    required this.assessments,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.auth.currentUser?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.assessments,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = widget.auth.currentUser;
    final assessmentCount = widget.assessments.assessments.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('Profile',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            await widget.auth
                                .updateDisplayName(_nameCtrl.text.trim());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Saved.')),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user?.email ??
                              (user?.isAnonymous == true
                                  ? 'Signed in anonymously'
                                  : 'Not signed in'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Gentle reminders',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _ReminderTile(
                  cadence: ReminderCadence.off,
                  current: widget.assessments.reminderCadence,
                  title: 'Off',
                  subtitle: 'No reminders.',
                  onSelect: (c) => widget.assessments.setReminderCadence(c),
                ),
                const Divider(height: 1),
                _ReminderTile(
                  cadence: ReminderCadence.weekly,
                  current: widget.assessments.reminderCadence,
                  title: 'Every Sabbath',
                  subtitle: 'A quiet nudge on Sunday mornings.',
                  onSelect: (c) => widget.assessments.setReminderCadence(c),
                ),
                const Divider(height: 1),
                _ReminderTile(
                  cadence: ReminderCadence.monthly,
                  current: widget.assessments.reminderCadence,
                  title: 'Once a month',
                  subtitle: 'On the first of each month.',
                  onSelect: (c) => widget.assessments.setReminderCadence(c),
                ),
                if (widget.assessments.reminderCadence != ReminderCadence.off)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Notifications fire on iOS and Android. The web preview saves your preference.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Your reflections',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              leading: const Icon(Icons.history),
              title: Text('$assessmentCount saved'),
              subtitle: const Text(
                  'Stored on this device. Cloud sync coming with Firebase.'),
            ),
          ),
          const SizedBox(height: 24),
          Text('About',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Source: Preach My Gospel, Ch. 6'),
                  subtitle: const Text(
                      'Statements © Intellectual Reserve, Inc. Used for personal devotional reflection.'),
                  onTap: () async {
                    await launchUrl(
                      Uri.parse(
                          'https://www.churchofjesuschrist.org/study/manual/preach-my-gospel-2023/14-chapter-6'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Like Him'),
                  subtitle: const Text('Version 0.1.0 · Built with Flutter'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text(
                      'Your reflections stay on this device. Signing in again on this device will keep them.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await widget.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final ReminderCadence cadence;
  final ReminderCadence current;
  final String title;
  final String subtitle;
  final ValueChanged<ReminderCadence> onSelect;

  const _ReminderTile({
    required this.cadence,
    required this.current,
    required this.title,
    required this.subtitle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = cadence == current;
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => onSelect(cadence),
    );
  }
}
