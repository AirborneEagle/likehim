# CLAA — Christlike Attribute Activity

A quiet, premium-feeling Flutter app for tracking the **Christlike Attribute Activity** from chapter 6 of *Preach My Gospel: A Guide to Sharing the Gospel of Jesus Christ* (2023).

You take an assessment, rate each statement under each of the ten attributes (Faith, Hope, Charity & Love, Virtue, Integrity, Knowledge, Patience, Humility, Diligence, Obedience) on the 1–5 *Never → Always* scale, and the app remembers it forever. A radar chart shows your current attribute profile; line charts show how each attribute moves over time. Every scripture reference taps through to that verse on [churchofjesuschrist.org](https://www.churchofjesuschrist.org/).

> Statements are reproduced verbatim from *Preach My Gospel*, © Intellectual Reserve, Inc. The app is for personal devotional reflection.

---

## Try it right now

A development web server should still be running on:

```
http://localhost:8765
```

Open that URL in any browser to see the app.

If the server is no longer up, restart it with:

```bash
cd C:\Users\tyler\Documents\code\claa\build\web
python -m http.server 8765
```

(rebuild first with `flutter build web --release` if the source changed)

---

## Status

| Layer | State |
|---|---|
| All 10 attributes + statements | ✅ Verbatim from PMG 2023, Ch. 6 |
| Auth (anonymous + email) | ✅ Local-only — Firebase wired but commented (see below) |
| Local persistence | ✅ via `shared_preferences` |
| Cloud sync | ⏳ Needs your Firebase project (steps below) |
| Radar chart of latest assessment | ✅ |
| Per-attribute line chart over time | ✅ |
| Scripture deep links | ✅ Open `churchofjesuschrist.org` |
| Web build | ✅ Tested |
| Android build | ⏳ Needs Android Studio + Android SDK installed |
| iOS build | ⏳ Needs a Mac with Xcode (you can't build iOS from Windows) |
| Play Store / App Store listing | ⏳ Needs your developer accounts |

---

## What I did automatically while you were away

1. Cloned the **Flutter SDK 3.41.9 (stable)** to `C:\flutter`
2. Bootstrapped the **Dart SDK** (downloaded automatically by Flutter)
3. Generated the Flutter project structure (`flutter create`)
4. Wrote ~3,000 lines of Dart implementing every screen
5. Pulled the verbatim CLAA statements from *Preach My Gospel 2023, Chapter 6* on `churchofjesuschrist.org`
6. Compiled a **release web build** (`build/web/`)
7. Started a local web server at **http://localhost:8765**

## Things I left for you (because they need *your* identity / payment info)

These each have explicit instructions below.

1. **Firebase project + flutterfire configure** — for cloud sync of assessments across devices
2. **Android Studio + Android SDK** — required to build the APK
3. **A Mac with Xcode** — required to build for iOS (cannot be done on Windows)
4. **Apple Developer account** ($99/yr) and **Google Play Console** ($25 one-time) — for store submission
5. **App icon + splash assets** — currently using a generic gradient mark; you may want a real designed icon

---

## How to add the global Flutter to your PATH

I cloned Flutter into `C:\flutter`. To use `flutter` and `dart` from any terminal:

1. Open **System Properties → Environment Variables**
2. Under **User variables**, edit `Path`
3. Add a new entry: `C:\flutter\bin`
4. Restart your terminal

Verify with `flutter --version`.

---

## Set up Firebase (for cloud sync)

The app currently stores assessments in `shared_preferences` (i.e. local to the device). All the code is structured so that swapping in Firebase is a small change — only `lib/services/auth_service.dart` and `lib/services/assessment_service.dart` need to change. Here's the path:

### 1. Create a Firebase project

1. Go to <https://console.firebase.google.com> and sign in with your Google account.
2. Click **Add project**, name it something like `claa-app`, accept the terms, **disable** Google Analytics (you don't need it for this).
3. Wait ~30 seconds for provisioning.

### 2. Enable Auth + Firestore

In your Firebase console:

1. **Build → Authentication → Get started**. Enable **Anonymous** and **Email/Password** sign-in.
2. **Build → Firestore Database → Create database**. Start in **production mode**, region `us-central` (or whatever's closest). Then add this security rule (Rules tab):

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid}/assessments/{doc} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```

   Click **Publish**.

### 3. Install the FlutterFire CLI

In a terminal with Flutter on PATH:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

Sign in to Firebase with the same Google account, pick the platforms you care about (Web, Android, iOS), and the CLI will generate `lib/firebase_options.dart` and platform config files (Android `google-services.json`, iOS `GoogleService-Info.plist`).

### 4. Uncomment Firebase code

In `pubspec.yaml`, uncomment:

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
```

In `lib/main.dart`, uncomment the `Firebase.initializeApp(...)` block and the imports above it.

Then run:

```bash
flutter pub get
flutter run
```

You can then swap the bodies of `auth_service.dart` and `assessment_service.dart` to use FirebaseAuth + Firestore. The rest of the app talks to those services through their public API, so no UI changes are needed.

---

## Build for Android

You need:

1. **Android Studio** (installs Android SDK + emulator) — <https://developer.android.com/studio>
2. **Java JDK 17+** (Android Studio bundles one)

Then:

```bash
flutter doctor --android-licenses   # accept licenses
flutter build apk --release         # → build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release   # for Play Store: → build/app/outputs/bundle/release/app-release.aab
```

To **publish on Play Store**:

1. Create a [Play Console](https://play.google.com/console/) account ($25 one-time)
2. Generate a signing keystore (`keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`)
3. Create `android/key.properties` with the keystore details
4. Configure signing in `android/app/build.gradle`
5. Upload the `.aab` to Play Console, fill out the listing, submit for review

Detailed walkthrough: <https://docs.flutter.dev/deployment/android>

---

## Build for iOS

iOS builds **must** happen on a Mac with Xcode. You cannot build iOS apps on Windows — Apple does not provide their SDK for Windows. Workarounds:

- Get a Mac (or Mac mini)
- Use [Codemagic](https://codemagic.io) or [GitHub Actions with macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners) to build iOS in CI

Once you're on a Mac with Xcode:

```bash
flutter build ipa --release
```

To **publish on the App Store**:

1. Create an [Apple Developer account](https://developer.apple.com/programs/) ($99/yr)
2. Set up an App ID + provisioning profile
3. Use Xcode or `xcrun altool` to upload the `.ipa` to App Store Connect
4. Fill out the listing in App Store Connect, submit for review

Detailed walkthrough: <https://docs.flutter.dev/deployment/ios>

---

## Project layout

```
lib/
├── main.dart                 entry point
├── app.dart                  root widget — bootstraps services, routes auth ↔ home
├── data/
│   └── claa_data.dart        all 10 attributes + every statement, verbatim
├── models/
│   ├── attribute.dart
│   ├── question.dart
│   └── assessment.dart       handles ratings, attribute averages, completion
├── services/
│   ├── auth_service.dart     anonymous + email auth (locally-backed)
│   └── assessment_service.dart  CRUD for assessments + draft persistence
├── theme/
│   └── theme.dart            warm parchment / midnight-blue palette, Fraunces + Inter
├── widgets/
│   ├── rating_selector.dart        5-step Never→Always selector
│   ├── attribute_icon.dart         per-attribute Material icon + avatar
│   ├── attribute_radar_chart.dart
│   └── attribute_history_chart.dart
└── screens/
    ├── splash_screen.dart
    ├── auth_screen.dart
    ├── home_screen.dart
    ├── questionnaire_screen.dart   paginated by attribute, draft auto-saves
    ├── results_screen.dart         radar + highlights after each save
    ├── attribute_detail_screen.dart
    ├── history_screen.dart         every attribute's line chart
    └── settings_screen.dart
```

---

## Design choices

- **Anonymous-first:** new users land in the app with one tap. They can later upgrade to a real account without losing data.
- **Drafts persist:** if you leave mid-assessment, the home screen invites you to *Resume* exactly where you stopped.
- **Premium feel:** Material 3, warm parchment in light mode and deep midnight blue in dark mode, Fraunces (serif) for display headings, Inter for body, generous spacing and soft shadows.
- **Compare snapshots:** the radar chart on the results screen overlays your previous reflection against the current one in a different color.
- **Scripture chips:** every reference is a tappable chip that opens that exact verse on `churchofjesuschrist.org` in your browser.
- **Local-first:** the app works fully offline. Cloud sync (Firebase) is purely additive.

## License

The app code is yours. The CLAA statements quoted from *Preach My Gospel* remain © Intellectual Reserve, Inc. and are reproduced for personal devotional reflection. If you publish this on the Play Store / App Store, the listing description should credit *Preach My Gospel* as the source.
