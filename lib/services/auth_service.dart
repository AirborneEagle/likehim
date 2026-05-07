import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Lightweight anonymous-first auth.
///
/// Anonymous mode generates a stable local user id stored in SharedPreferences
/// so all data on this device belongs to the same "account" until the user
/// chooses to upgrade.
///
/// When Firebase is wired up (see README), replace the bodies of [signInAnon],
/// [signUpWithEmail], [signInWithEmail], and [signOut] with the corresponding
/// FirebaseAuth calls. The rest of the app talks to AppUser, not Firebase.
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
  static const _kUserIdKey = 'claa.userId';
  static const _kEmailKey = 'claa.email';
  static const _kNameKey = 'claa.displayName';
  static const _kAnonKey = 'claa.isAnonymous';

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserIdKey);
    if (id == null) {
      _currentUser = null;
    } else {
      _currentUser = AppUser(
        id: id,
        email: prefs.getString(_kEmailKey),
        displayName: prefs.getString(_kNameKey),
        isAnonymous: prefs.getBool(_kAnonKey) ?? true,
      );
    }
    notifyListeners();
  }

  Future<AppUser> signInAnon({String? displayName}) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserIdKey) ?? const Uuid().v4();
    await prefs.setString(_kUserIdKey, id);
    await prefs.setBool(_kAnonKey, true);
    if (displayName != null && displayName.isNotEmpty) {
      await prefs.setString(_kNameKey, displayName);
    }
    _currentUser = AppUser(
      id: id,
      displayName: displayName ?? prefs.getString(_kNameKey),
      isAnonymous: true,
    );
    notifyListeners();
    return _currentUser!;
  }

  /// Stub for "create an account" — currently treats it as a local
  /// upgrade (no Firebase). Records the email & display name on the
  /// existing local user so we keep all their data.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserIdKey) ?? const Uuid().v4();
    await prefs.setString(_kUserIdKey, id);
    await prefs.setString(_kEmailKey, email);
    if (displayName != null && displayName.isNotEmpty) {
      await prefs.setString(_kNameKey, displayName);
    }
    await prefs.setBool(_kAnonKey, false);
    _currentUser = AppUser(
      id: id,
      email: email,
      displayName: displayName ?? prefs.getString(_kNameKey),
      isAnonymous: false,
    );
    notifyListeners();
    return _currentUser!;
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserIdKey) ?? const Uuid().v4();
    await prefs.setString(_kUserIdKey, id);
    await prefs.setString(_kEmailKey, email);
    await prefs.setBool(_kAnonKey, false);
    _currentUser = AppUser(
      id: id,
      email: email,
      displayName: prefs.getString(_kNameKey),
      isAnonymous: false,
    );
    notifyListeners();
    return _currentUser!;
  }

  Future<void> updateDisplayName(String name) async {
    final user = _currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNameKey, name);
    _currentUser = AppUser(
      id: user.id,
      email: user.email,
      displayName: name,
      isAnonymous: user.isAnonymous,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kNameKey);
    await prefs.remove(_kAnonKey);
    _currentUser = null;
    notifyListeners();
  }
}
