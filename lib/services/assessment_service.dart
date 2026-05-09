import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/attributes_data.dart';
import '../models/assessment.dart';

enum ReminderCadence { off, weekly, monthly }

/// Whether the user is currently serving a full-time mission. Drives which
/// rendering of the four mission-specific statements they see — same
/// question id, same conceptual attribute, just different phrasing.
/// Default is [member] because most users aren't currently on a mission.
enum Audience { member, missionary }

/// Firestore-backed assessment store.
///
/// Layout:
///   users/{uid}                              (state doc)
///     fields: draft (Map?), focusAttributeId (String?),
///             focusSetAtMs (int?), reminderCadenceIdx (int)
///   users/{uid}/assessments/{assessmentId}   (one doc per saved reflection)
///     fields: id, takenAtMs, ratings (Map<String,int>), note (String?)
///
/// Firestore offline persistence is enabled by default on mobile and on web,
/// so reads come from the cache instantly when offline and writes are queued.
class AssessmentService extends ChangeNotifier {
  AssessmentService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _userId;
  List<Assessment> _assessments = [];
  Assessment? _draft;
  bool _loaded = false;

  String? _focusAttributeId;
  DateTime? _focusSetAt;
  ReminderCadence _reminderCadence = ReminderCadence.off;
  Audience _audience = Audience.member;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _assessmentsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  List<Assessment> get assessments => List.unmodifiable(_assessments);
  Assessment? get draft => _draft;
  bool get isLoaded => _loaded;

  String? get focusAttributeId => _focusAttributeId;
  DateTime? get focusSetAt => _focusSetAt;
  ReminderCadence get reminderCadence => _reminderCadence;
  Audience get audience => _audience;

  Assessment? get latestComplete {
    final completed =
        _assessments.where((a) => a.isComplete).toList(growable: false);
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return completed.first;
  }

  CollectionReference<Map<String, dynamic>> get _assessmentsCol =>
      _db.collection('users').doc(_userId).collection('assessments');
  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_userId);

  Future<void> bindUser(String userId) async {
    if (_userId == userId && _loaded) return;
    await _assessmentsSub?.cancel();
    await _userDocSub?.cancel();
    _userId = userId;
    _loaded = false;

    // Synchronously fetch the initial state so the UI doesn't flash empty.
    await Future.wait([
      _primeAssessments(),
      _primeUserDoc(),
    ]);
    _loaded = true;
    notifyListeners();

    // Then subscribe for live updates (cross-device sync).
    _assessmentsSub = _assessmentsCol
        .orderBy('takenAtMs', descending: true)
        .snapshots()
        .listen(_applyAssessmentsSnapshot);
    _userDocSub = _userDoc.snapshots().listen(_applyUserDocSnapshot);
  }

  Future<void> _primeAssessments() async {
    final snap = await _assessmentsCol
        .orderBy('takenAtMs', descending: true)
        .get();
    _applyAssessmentsSnapshot(snap);
  }

  Future<void> _primeUserDoc() async {
    final snap = await _userDoc.get();
    _applyUserDocSnapshot(snap);
  }

  void _applyAssessmentsSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    _assessments = snap.docs
        .map((d) => _assessmentFromDoc(d.id, d.data()))
        .toList(growable: false);
    notifyListeners();
  }

  void _applyUserDocSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? const <String, dynamic>{};
    final draftMap = data['draft'];
    _draft = (draftMap is Map<String, dynamic>)
        ? _assessmentFromDoc(draftMap['id'] as String? ?? const Uuid().v4(),
            draftMap)
        : null;
    _focusAttributeId = data['focusAttributeId'] as String?;
    final focusAtMs = data['focusSetAtMs'];
    _focusSetAt = focusAtMs is int
        ? DateTime.fromMillisecondsSinceEpoch(focusAtMs)
        : null;
    final cadenceIdx = (data['reminderCadenceIdx'] as int?) ?? 0;
    _reminderCadence = ReminderCadence
        .values[cadenceIdx.clamp(0, ReminderCadence.values.length - 1)];
    final audienceIdx = (data['audienceIdx'] as int?) ?? 0;
    _audience =
        Audience.values[audienceIdx.clamp(0, Audience.values.length - 1)];
    notifyListeners();
  }

  Assessment _assessmentFromDoc(String id, Map<String, dynamic> data) {
    final ratingsRaw = data['ratings'];
    final ratings = <String, int>{};
    if (ratingsRaw is Map) {
      ratingsRaw.forEach((k, v) {
        if (v is num) ratings[k.toString()] = v.toInt();
      });
    }
    final takenAtMs = data['takenAtMs'];
    final takenAt = takenAtMs is int
        ? DateTime.fromMillisecondsSinceEpoch(takenAtMs)
        : (data['takenAt'] is String
            ? DateTime.parse(data['takenAt'] as String)
            : DateTime.now());
    return Assessment(
      id: id,
      takenAt: takenAt,
      ratings: ratings,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> _assessmentToDoc(Assessment a) => {
        'id': a.id,
        'takenAtMs': a.takenAt.millisecondsSinceEpoch,
        'ratings': a.ratings,
        'note': a.note,
      };

  Future<void> setFocus(String? attributeId) async {
    _focusAttributeId = attributeId;
    _focusSetAt = attributeId == null ? null : DateTime.now();
    notifyListeners();
    if (_userId == null) return;
    await _userDoc.set({
      'focusAttributeId': attributeId,
      'focusSetAtMs': _focusSetAt?.millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Future<void> setReminderCadence(ReminderCadence cadence) async {
    _reminderCadence = cadence;
    notifyListeners();
    if (_userId == null) return;
    await _userDoc.set(
      {'reminderCadenceIdx': cadence.index},
      SetOptions(merge: true),
    );
  }

  Future<void> setAudience(Audience audience) async {
    _audience = audience;
    notifyListeners();
    if (_userId == null) return;
    await _userDoc.set(
      {'audienceIdx': audience.index},
      SetOptions(merge: true),
    );
  }

  Assessment startOrResumeDraft() {
    _draft ??= Assessment(
      id: const Uuid().v4(),
      takenAt: DateTime.now(),
      ratings: <String, int>{},
    );
    notifyListeners();
    _writeDraft();
    return _draft!;
  }

  Future<void> _writeDraft() async {
    if (_userId == null) return;
    await _userDoc.set(
      {'draft': _draft == null ? null : _assessmentToDoc(_draft!)},
      SetOptions(merge: true),
    );
  }

  Future<void> setRating(String questionId, int rating) async {
    final current = _draft ?? startOrResumeDraft();
    final next = Map<String, int>.from(current.ratings);
    next[questionId] = rating;
    _draft = current.copyWith(ratings: next);
    notifyListeners();
    await _writeDraft();
  }

  Future<void> setNote(String? note) async {
    final current = _draft ?? startOrResumeDraft();
    _draft = current.copyWith(note: note);
    notifyListeners();
    await _writeDraft();
  }

  Future<void> discardDraft() async {
    _draft = null;
    notifyListeners();
    if (_userId == null) return;
    await _userDoc.set({'draft': null}, SetOptions(merge: true));
  }

  /// Persist the draft to the historical list. Returns the saved assessment.
  Future<Assessment> finishDraft({String? note}) async {
    final current = _draft;
    if (current == null) {
      throw StateError('No draft to finish.');
    }
    final saved = current.copyWith(note: note ?? current.note);
    _assessments = [saved, ..._assessments]
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    _draft = null;
    notifyListeners();

    if (_userId != null) {
      final batch = _db.batch();
      batch.set(
        _assessmentsCol.doc(saved.id),
        _assessmentToDoc(saved),
      );
      batch.set(
        _userDoc,
        {'draft': null},
        SetOptions(merge: true),
      );
      await batch.commit();
    }
    return saved;
  }

  Future<void> deleteAssessment(String id) async {
    _assessments.removeWhere((a) => a.id == id);
    notifyListeners();
    if (_userId == null) return;
    await _assessmentsCol.doc(id).delete();
  }

  /// Returns assessments oldest-first (handy for line charts).
  List<Assessment> chronological() {
    return List<Assessment>.from(_assessments)
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));
  }

  // -- Dev/testing helpers ----------------------------------------------------

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
    notifyListeners();
    await _writeDraft();
  }

  Future<void> seedRandomHistory({int count = 8}) async {
    final rand = math.Random();
    final now = DateTime.now();
    final additions = <Assessment>[];
    for (var i = 0; i < count; i++) {
      final ratings = <String, int>{};
      for (var aIdx = 0; aIdx < kAttributes.length; aIdx++) {
        final a = kAttributes[aIdx];
        final attrBase = 2.4 + ((aIdx * 0.37) % 1.5);
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
          takenAt: now.subtract(
            Duration(days: (count - 1 - i) * 14 + rand.nextInt(7)),
          ),
          ratings: ratings,
        ),
      );
    }
    _assessments = [...additions, ..._assessments]
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    notifyListeners();
    if (_userId == null) return;
    final batch = _db.batch();
    for (final a in additions) {
      batch.set(_assessmentsCol.doc(a.id), _assessmentToDoc(a));
    }
    await batch.commit();
  }

  Future<void> clearAllForTesting() async {
    final ids = _assessments.map((a) => a.id).toList(growable: false);
    _assessments = [];
    _draft = null;
    _focusAttributeId = null;
    _focusSetAt = null;
    notifyListeners();
    if (_userId == null) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_assessmentsCol.doc(id));
    }
    batch.set(
      _userDoc,
      {
        'draft': null,
        'focusAttributeId': null,
        'focusSetAtMs': null,
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  void dispose() {
    _assessmentsSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}
