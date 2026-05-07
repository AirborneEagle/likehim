import '../data/claa_data.dart';

class Assessment {
  final String id;
  final DateTime takenAt;
  // Map of question id -> 1..5 rating
  final Map<String, int> ratings;
  final String? note;

  Assessment({
    required this.id,
    required this.takenAt,
    required this.ratings,
    this.note,
  });

  /// Average score for a single attribute (1.0 - 5.0). Returns null if no
  /// questions for the attribute have been answered.
  double? attributeScore(String attributeId) {
    final attr = kAttributes.firstWhere((a) => a.id == attributeId);
    final answered = attr.questions
        .map((q) => ratings[q.id])
        .whereType<int>()
        .toList();
    if (answered.isEmpty) return null;
    return answered.reduce((a, b) => a + b) / answered.length;
  }

  Map<String, double?> attributeScores() {
    return {
      for (final a in kAttributes) a.id: attributeScore(a.id),
    };
  }

  /// Overall average across every answered question.
  double? overallScore() {
    if (ratings.isEmpty) return null;
    final values = ratings.values.toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  bool get isComplete {
    final total = kAttributes.fold<int>(0, (a, b) => a + b.questions.length);
    return ratings.length >= total;
  }

  int get answeredCount => ratings.length;

  int get totalQuestions =>
      kAttributes.fold<int>(0, (a, b) => a + b.questions.length);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'takenAt': takenAt.toIso8601String(),
      'ratings': ratings,
      'note': note,
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    final raw = map['ratings'];
    final Map<String, int> ratings = {};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is int) {
          ratings[k.toString()] = v;
        } else if (v is num) {
          ratings[k.toString()] = v.toInt();
        }
      });
    }
    return Assessment(
      id: map['id'] as String,
      takenAt: DateTime.parse(map['takenAt'] as String),
      ratings: ratings,
      note: map['note'] as String?,
    );
  }

  Assessment copyWith({Map<String, int>? ratings, String? note}) {
    return Assessment(
      id: id,
      takenAt: takenAt,
      ratings: ratings ?? this.ratings,
      note: note ?? this.note,
    );
  }
}
