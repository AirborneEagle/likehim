import '../data/attributes_data.dart';

/// A single scripture reference + its deep-link path on churchofjesuschrist.org.
/// A question may have multiple of these — render one chip per ref.
class ScriptureRef {
  final String ref;
  final String path;
  const ScriptureRef({required this.ref, required this.path});

  String get url => '$kChurchHost$path';
}

class Question {
  final String id;
  final String text;
  /// Alternate phrasing for users who aren't currently serving a full-time
  /// mission. Null for the ~50 statements that work for everyone as-is;
  /// populated only for the few statements that reference mission life
  /// directly. Same id and same conceptual attribute — only the rendered
  /// string changes, so historical scores keep tracking the same thing.
  final String? lifeText;
  final List<ScriptureRef> scriptures;

  const Question({
    required this.id,
    required this.text,
    this.lifeText,
    this.scriptures = const [],
  });
}
