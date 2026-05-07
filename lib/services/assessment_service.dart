import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/claa_data.dart';
import '../models/assessment.dart';

/// Stores assessments locally in SharedPreferences.
///
/// To switch this to Firestore, replace the bodies of the public methods to
/// read/write the `users/{uid}/assessments` collection while keeping the
/// in-memory list in sync. The rest of the app only depends on the public
/// surface of this class.
/// Cadence options for the gentle reminder. Actual notification delivery is
/// wired up only in the iOS / Android builds — see README. On web we just
/// persist the preference.
enum ReminderCadence { off, weekly, monthly }

class AssessmentService extends ChangeNotifier {
  AssessmentService();

  String? _userId;
  List<Assessment> _assessments = [];
  Assessment? _draft;
  bool _loaded = false;

  String? _focusAttributeId;
  DateTime? _focusSetAt;
  ReminderCadence _reminderCadence = ReminderCadence.off;

  List<Assessment> get assessments => List.unmodifiable(_assessments);
  Assessment? get draft => _draft;
  bool get isLoaded => _loaded;

  String? get focusAttributeId => _focusAttributeId;
  DateTime? get focusSetAt => _focusSetAt;
  ReminderCadence get reminderCadence => _reminderCadence;

  Assessment? get latestComplete {
    final completed =
        _assessments.where((a) => a.isComplete).toList(growable: false);
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return completed.first;
  }

  String _key(String suffix) => 'claa.assessments.$_userId.$suffix';

  Future<void> bindUser(String userId) async {
    if (_userId == userId && _loaded) return;
    _userId = userId;
    await _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key('list')) ?? '[]';
    try {
      final list = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(Assessment.fromMap)
          .toList();
      list.sort((a, b) => b.takenAt.compareTo(a.takenAt));
      _assessments = list;
    } catch (_) {
      _assessments = [];
    }
    final draftRaw = prefs.getString(_key('draft'));
    if (draftRaw != null) {
      try {
        _draft = Assessment.fromMap(
            jsonDecode(draftRaw) as Map<String, dynamic>);
      } catch (_) {
        _draft = null;
      }
    } else {
      _draft = null;
    }
    _focusAttributeId = prefs.getString(_key('focus.id'));
    final focusAtMs = prefs.getInt(_key('focus.setAt'));
    _focusSetAt =
        focusAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(focusAtMs);
    final cadenceIdx = prefs.getInt(_key('reminder.cadence')) ?? 0;
    _reminderCadence = ReminderCadence.values[
        cadenceIdx.clamp(0, ReminderCadence.values.length - 1)];
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final list =
        _assessments.map((a) => a.toMap()).toList(growable: false);
    await prefs.setString(_key('list'), jsonEncode(list));
    if (_draft == null) {
      await prefs.remove(_key('draft'));
    } else {
      await prefs.setString(_key('draft'), jsonEncode(_draft!.toMap()));
    }
    if (_focusAttributeId == null) {
      await prefs.remove(_key('focus.id'));
      await prefs.remove(_key('focus.setAt'));
    } else {
      await prefs.setString(_key('focus.id'), _focusAttributeId!);
      await prefs.setInt(
        _key('focus.setAt'),
        (_focusSetAt ?? DateTime.now()).millisecondsSinceEpoch,
      );
    }
    await prefs.setInt(_key('reminder.cadence'), _reminderCadence.index);
  }

  /// Set the attribute the user wants to "sit with" between reflections.
  /// Pass null to clear the focus.
  Future<void> setFocus(String? attributeId) async {
    _focusAttributeId = attributeId;
    _focusSetAt = attributeId == null ? null : DateTime.now();
    await _persist();
    notifyListeners();
  }

  Future<void> setReminderCadence(ReminderCadence cadence) async {
    _reminderCadence = cadence;
    await _persist();
    notifyListeners();
  }

  /// Creates an empty draft assessment if none exists, or returns the in-flight
  /// one so users don't lose progress.
  Assessment startOrResumeDraft() {
    _draft ??= Assessment(
      id: const Uuid().v4(),
      takenAt: DateTime.now(),
      ratings: <String, int>{},
    );
    notifyListeners();
    return _draft!;
  }

  Future<void> setRating(String questionId, int rating) async {
    final current = _draft ?? startOrResumeDraft();
    final next = Map<String, int>.from(current.ratings);
    next[questionId] = rating;
    _draft = current.copyWith(ratings: next);
    await _persist();
    notifyListeners();
  }

  Future<void> setNote(String? note) async {
    final current = _draft ?? startOrResumeDraft();
    _draft = current.copyWith(note: note);
    await _persist();
    notifyListeners();
  }

  Future<void> discardDraft() async {
    _draft = null;
    await _persist();
    notifyListeners();
  }

  /// Persist the draft to the historical list. Returns the saved assessment.
  Future<Assessment> finishDraft({String? note}) async {
    final current = _draft;
    if (current == null) {
      throw StateError('No draft to finish.');
    }
    final saved = current.copyWith(
      note: note ?? current.note,
    );
    _assessments = [saved, ..._assessments]
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    _draft = null;
    await _persist();
    notifyListeners();
    return saved;
  }

  Future<void> deleteAssessment(String id) async {
    _assessments.removeWhere((a) => a.id == id);
    await _persist();
    notifyListeners();
  }

  /// Returns assessments oldest-first (handy for line charts).
  List<Assessment> chronological() {
    return List<Assessment>.from(_assessments)
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));
  }

  // -- Dev/testing helpers ----------------------------------------------------

  /// Fill the in-flight draft with a random rating (1–5) for every question.
  /// Surfaced via the hidden long-press dev menu.
  Future<void> fillCurrentDraftRandomly() async {
    final rand = math.Random();
    final ratings = <String, int>{};
    for (final a in kAttributes) {
      for (final q in a.questions) {
        ratings[q.id] = 1 + rand.nextInt(5);
      }
    }
    final base = _draft ?? startOrResumeDraft();
    _draft = base.copyWith(ratings: ratings);
    await _persist();
    notifyListeners();
  }

  /// Generate [count] historical complete assessments at past timestamps. Each
  /// rating drifts gently upward over time so trend lines look interesting.
  Future<void> seedRandomHistory({int count = 8}) async {
    final rand = math.Random();
    final now = DateTime.now();
    final additions = <Assessment>[];
    for (var i = 0; i < count; i++) {
      final ratings = <String, int>{};
      // Each per-question center is biased per-attribute so radar shapes vary,
      // and trends upward across reflections.
      for (var aIdx = 0; aIdx < kAttributes.length; aIdx++) {
        final a = kAttributes[aIdx];
        // Per-attribute baseline that varies (some attrs naturally weaker)
        final attrBase = 2.4 + ((aIdx * 0.37) % 1.5);
        // Time progression: later reflections lean higher
        final timeBoost = (i / (count - 1).clamp(1, 999)) * 0.9;
        final center = (attrBase + timeBoost).clamp(1.5, 4.5);
        for (final q in a.questions) {
          final jitter = (rand.nextDouble() - 0.5) * 1.6;
          final v = (center + jitter).round().clamp(1, 5);
          ratings[q.id] = v;
        }
      }
      additions.add(
        Assessment(
          id: const Uuid().v4(),
          // Most recent ones are newest, spaced ~14 days apart
          takenAt: now.subtract(
            Duration(days: (count - 1 - i) * 14 + rand.nextInt(7)),
          ),
          ratings: ratings,
        ),
      );
    }
    _assessments = [...additions, ..._assessments]
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    await _persist();
    notifyListeners();
  }

  /// Wipe every saved reflection plus the in-flight draft for the bound user.
  Future<void> clearAllForTesting() async {
    _assessments = [];
    _draft = null;
    _focusAttributeId = null;
    _focusSetAt = null;
    await _persist();
    notifyListeners();
  }
}
