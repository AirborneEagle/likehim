import 'package:flutter/material.dart';

/// Maps attribute id -> a Material icon. Keeps each attribute visually
/// recognisable without bringing in custom icon fonts.
IconData iconForAttribute(String id) {
  switch (id) {
    case 'faith':
      return Icons.auto_awesome_outlined;
    case 'hope':
      return Icons.wb_sunny_outlined;
    case 'charity':
      return Icons.favorite_border;
    case 'virtue':
      return Icons.spa_outlined;
    case 'integrity':
      return Icons.verified_outlined;
    case 'knowledge':
      return Icons.menu_book_outlined;
    case 'patience':
      return Icons.hourglass_empty;
    case 'humility':
      return Icons.self_improvement_outlined;
    case 'diligence':
      return Icons.bolt_outlined;
    case 'obedience':
      return Icons.shield_outlined;
    default:
      return Icons.circle_outlined;
  }
}

class AttributeAvatar extends StatelessWidget {
  final String id;
  final Color color;
  final double size;
  const AttributeAvatar({
    super.key,
    required this.id,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Icon(
        iconForAttribute(id),
        color: color,
        size: size * 0.55,
      ),
    );
  }
}
