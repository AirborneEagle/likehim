import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Surface uncaught Flutter errors to the JS console so we can see what
  // breaks on a release web build.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('CLAA flutter error: ${details.exceptionAsString()}');
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('CLAA Firebase.initializeApp failed: $e\n$st');
  }

  runApp(const ClaaApp());
}
