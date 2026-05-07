import 'package:flutter/material.dart';

import '../data/claa_data.dart';

/// Five-step segmented selector that maps to PMG's 1–5 frequency scale.
///
/// Selected value visually grows + uses primary color. Unselected values stay
/// pill-shaped with a soft surface background.
class RatingSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  final Color? accent;

  const RatingSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tint = accent ?? scheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(5, (i) {
            final n = i + 1;
            final selected = value == n;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 4 ? 0 : 6),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 76,
                    decoration: BoxDecoration(
                      color: selected
                          ? tint
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? tint
                            : scheme.outline.withValues(alpha: 0.4),
                        width: 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: tint.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$n',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kRatingLabels[i],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? scheme.onPrimary.withValues(alpha: 0.85)
                                : scheme.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
