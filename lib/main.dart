import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Set to a non-null value if [Firebase.initializeApp] threw on startup.
/// The app reads this and renders a diagnostic screen in place of the home.
Object? firebaseInitError;
StackTrace? firebaseInitStack;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Liken flutter error: ${details.exceptionAsString()}');
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    firebaseInitError = e;
    firebaseInitStack = st;
    debugPrint('Liken Firebase.initializeApp failed: $e\n$st');
  }

  runApp(const LikenApp());
}
