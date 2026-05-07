import '../data/claa_data.dart';

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
  final List<ScriptureRef> scriptures;

  const Question({
    required this.id,
    required this.text,
    this.scriptures = const [],
  });
}
