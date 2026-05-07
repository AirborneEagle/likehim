import 'package:flutter/material.dart';

import '../models/question.dart';
import '../utils/scripture_link.dart';

/// One pill that opens a single scripture reference on churchofjesuschrist.org.
class ScriptureChip extends StatelessWidget {
  final ScriptureRef scripture;
  final Color color;
  final bool compact;

  const ScriptureChip({
    super.key,
    required this.scripture,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padH = compact ? 10.0 : 12.0;
    final padV = compact ? 6.0 : 8.0;
    final iconSize = compact ? 12.0 : 14.0;
    final externalSize = compact ? 11.0 : 12.0;
    final style = (compact
            ? theme.textTheme.labelSmall
            : theme.textTheme.labelMedium)
        ?.copyWith(color: color, fontWeight: FontWeight.w600);

    return InkWell(
      onTap: () => openScripture(context, scripture.url),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: iconSize, color: color),
            const SizedBox(width: 6),
            Text(scripture.ref, style: style),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: externalSize, color: color),
          ],
        ),
      ),
    );
  }
}

/// Wrapping row of chips, one per scripture. Renders nothing when empty.
class ScriptureChipRow extends StatelessWidget {
  final List<ScriptureRef> scriptures;
  final Color color;
  final bool compact;

  const ScriptureChipRow({
    super.key,
    required this.scriptures,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (scriptures.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in scriptures)
          ScriptureChip(scripture: s, color: color, compact: compact),
      ],
    );
  }
}
