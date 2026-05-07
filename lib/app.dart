import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/assessment_service.dart';
import 'services/auth_service.dart';
import 'theme/theme.dart';

class ClaaApp extends StatefulWidget {
  const ClaaApp({super.key});

  @override
  State<ClaaApp> createState() => _ClaaAppState();
}

class _ClaaAppState extends State<ClaaApp> {
  final AuthService _auth = AuthService();
  final AssessmentService _assessments = AssessmentService();
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _auth.addListener(_handleAuthChanged);
  }

  Future<void> _bootstrap() async {
    await _auth.bootstrap();
    final user = _auth.currentUser;
    if (user != null) {
      await _assessments.bindUser(user.id);
    }
    if (mounted) {
      setState(() => _bootstrapped = true);
    }
  }

  Future<void> _handleAuthChanged() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _assessments.bindUser(user.id);
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
      title: 'CLAA',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: !_bootstrapped
          ? const SplashScreen()
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
