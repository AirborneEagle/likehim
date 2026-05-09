import 'package:flutter/material.dart';

import 'main.dart' show firebaseInitError;
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/assessment_service.dart';
import 'services/auth_service.dart';
import 'theme/theme.dart';

class LikeHimApp extends StatefulWidget {
  const LikeHimApp({super.key});

  @override
  State<LikeHimApp> createState() => _LikeHimAppState();
}

class _LikeHimAppState extends State<LikeHimApp> {
  final AuthService _auth = AuthService();
  final AssessmentService _assessments = AssessmentService();
  bool _bootstrapped = false;
  Object? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _auth.addListener(_handleAuthChanged);
  }

  Future<void> _bootstrap() async {
    // If Firebase.initializeApp blew up in main(), there's no point trying
    // to set up auth. Surface that error directly on screen.
    if (firebaseInitError != null) {
      _bootstrapError = firebaseInitError;
      if (mounted) setState(() => _bootstrapped = true);
      return;
    }
    try {
      await _auth.bootstrap();
      final user = _auth.currentUser;
      if (user != null) {
        await _assessments.bindUser(user.id);
      }
    } catch (e, st) {
      debugPrint('Like Him bootstrap error: $e\n$st');
      _bootstrapError = e;
    }
    if (mounted) {
      setState(() => _bootstrapped = true);
    }
  }

  Future<void> _handleAuthChanged() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _assessments.bindUser(user.id);
      } catch (e, st) {
        debugPrint('Like Him assessments.bindUser error: $e\n$st');
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Like Him',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: !_bootstrapped
          ? const SplashScreen()
          : _bootstrapError != null
              ? _BootstrapError(error: _bootstrapError!)
              : (_auth.currentUser == null
                  ? AuthScreen(
                      auth: _auth,
                      onSignedIn: () {},
                    )
                  : HomeScreen(
                      auth: _auth,
                      assessments: _assessments,
                    )),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  final Object error;
  const _BootstrapError({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final msg = error.toString();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 56, color: scheme.error),
              const SizedBox(height: 16),
              Text("Couldn't connect to Firebase",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'This usually means one of two things needs to be enabled in your Firebase console for project claa-49961:',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              const _Bullet(
                'Authentication → Sign-in method → enable "Anonymous"',
              ),
              const _Bullet(
                'Firestore Database → Create database (production mode)',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 10),
            child: Icon(Icons.check_circle_outline, size: 16),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
