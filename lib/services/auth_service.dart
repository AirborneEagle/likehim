import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase-backed auth.
///
/// Anonymous-first: on first run we sign the user in anonymously so they
/// have a stable uid. They can later upgrade to email/password without losing
/// data, because [signUpWithEmail] uses [User.linkWithCredential] when the
/// current user is anonymous — that preserves the uid (and therefore all
/// `users/{uid}/assessments` data in Firestore).
class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    required this.isAnonymous,
  });
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _fb = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  AppUser _from(User u) => AppUser(
        id: u.uid,
        email: u.email,
        displayName: u.displayName,
        isAnonymous: u.isAnonymous,
      );

  Future<void> bootstrap() async {
    // Seed from current state so the splash → home transition can read it
    // synchronously after `bootstrap()` resolves.
    final initial = _fb.currentUser;
    _currentUser = initial == null ? null : _from(initial);
    _sub ??= _fb.userChanges().listen(
      (u) {
        _currentUser = u == null ? null : _from(u);
        notifyListeners();
      },
      onError: (Object e, StackTrace st) {
        debugPrint('Like Him auth stream error: $e\n$st');
      },
    );
    notifyListeners();
  }

  Future<AppUser> signInAnon({String? displayName}) async {
    final cred = await _fb.signInAnonymously();
    final user = cred.user!;
    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    }
    final fresh = _fb.currentUser ?? user;
    _currentUser = _from(fresh);
    notifyListeners();
    return _currentUser!;
  }

  /// Create an account. If the current user is anonymous, link the email
  /// credential so the same uid (and all their existing data) carries over.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = _fb.currentUser;
    User user;
    if (current != null && current.isAnonymous) {
      final emailCred = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final linked = await current.linkWithCredential(emailCred);
      user = linked.user!;
    } else {
      final created = await _fb.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = created.user!;
    }
    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    }
    final fresh = _fb.currentUser ?? user;
    _currentUser = _from(fresh);
    notifyListeners();
    return _currentUser!;
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _fb.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _currentUser = _from(cred.user!);
    notifyListeners();
    return _currentUser!;
  }

  /// Sign in with Google. Uses the Firebase Auth OAuth flow directly —
  /// `signInWithPopup` on web (Firebase's native popup), `signInWithProvider`
  /// on mobile (Custom Tabs / SFSafariViewController under the hood).
  ///
  /// If the current user is anonymous, we LINK the Google credential to that
  /// user so the same uid (and all their existing reflection data) survives
  /// the upgrade. If linking fails because the Google account is already
  /// linked to another Firebase user, we fall back to signing into that
  /// existing account — losing the anonymous user's draft, which is the
  /// expected and unavoidable behavior in that case.
  Future<AppUser> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..setCustomParameters({'prompt': 'select_account'});

    final current = _fb.currentUser;
    UserCredential cred;
    try {
      if (current != null && current.isAnonymous) {
        // Anon → Google upgrade. Preserve uid + Firestore data.
        cred = kIsWeb
            ? await current.linkWithPopup(provider)
            : await current.linkWithProvider(provider);
      } else {
        cred = kIsWeb
            ? await _fb.signInWithPopup(provider)
            : await _fb.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (e) {
      // 'credential-already-in-use' / 'email-already-in-use': the Google
      // account is already a Firebase user. Sign in to that user instead.
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        cred = kIsWeb
            ? await _fb.signInWithPopup(provider)
            : await _fb.signInWithProvider(provider);
      } else {
        rethrow;
      }
    }

    _currentUser = _from(cred.user!);
    notifyListeners();
    return _currentUser!;
  }

  /// Sign in with Apple. iOS-only entry point; Apple Review Guideline 4.8
  /// requires this option whenever a third-party social login (Google) is
  /// offered. We use the native Apple sheet via `sign_in_with_apple`, then
  /// exchange the identity token for a Firebase OAuthCredential.
  ///
  /// As with Google, if the current user is anonymous we LINK the Apple
  /// credential so the same uid (and all reflection data) survives the
  /// upgrade. If linking fails because the Apple account is already a
  /// Firebase user, we fall back to signing into that account.
  Future<AppUser> signInWithApple() async {
    // Apple's flow expects a SHA256-hashed nonce; we generate a raw nonce
    // and hash it so the identity token Apple returns is bound to it.
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final oauth = OAuthProvider('apple.com').credential(
      idToken: appleCred.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCred.authorizationCode,
    );

    final current = _fb.currentUser;
    UserCredential cred;
    try {
      if (current != null && current.isAnonymous) {
        cred = await current.linkWithCredential(oauth);
      } else {
        cred = await _fb.signInWithCredential(oauth);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        cred = await _fb.signInWithCredential(oauth);
      } else {
        rethrow;
      }
    }

    // Apple only sends the user's full name on the FIRST sign-in for a given
    // app — subsequent sign-ins return null for givenName/familyName. Persist
    // it to the Firebase profile while we have it.
    final displayName = [appleCred.givenName, appleCred.familyName]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ');
    if (displayName.isNotEmpty &&
        (cred.user!.displayName == null || cred.user!.displayName!.isEmpty)) {
      await cred.user!.updateDisplayName(displayName);
      await cred.user!.reload();
    }

    final fresh = _fb.currentUser ?? cred.user!;
    _currentUser = _from(fresh);
    notifyListeners();
    return _currentUser!;
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  Future<void> updateDisplayName(String name) async {
    final user = _fb.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
    await user.reload();
    final fresh = _fb.currentUser!;
    _currentUser = _from(fresh);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _fb.signOut();
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
