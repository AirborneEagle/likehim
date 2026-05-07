import 'question.dart';

class Attribute {
  final String id;
  final String name;
  final String shortName;
  final String icon;
  final int color;
  final String description;
  final List<Question> questions;

  const Attribute({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.color,
    required this.description,
    required this.questions,
  });
}
