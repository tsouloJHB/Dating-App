import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Initializes Firebase when configuration exists.
///
/// **Web:** `Firebase.initializeApp()` without [FirebaseOptions] throws. If you
/// use Firebase on web, either run `flutterfire configure` and import
/// `firebase_options.dart`, or pass defines:
/// `FIREBASE_WEB_API_KEY`, `FIREBASE_WEB_APP_ID`, `FIREBASE_PROJECT_ID`, and
/// optionally `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_AUTH_DOMAIN`,
/// `FIREBASE_STORAGE_BUCKET`.
///
/// If those are unset, initialization is skipped (Google Sign-In uses Better
/// Auth, not Firebase Auth, in this project).
Future<void> ensureFirebaseInitialized() async {
  if (kIsWeb) {
    const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if (apiKey.isEmpty || appId.isEmpty || projectId.isEmpty) {
      return;
    }
    const messagingSenderId =
        String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId:
            messagingSenderId.isEmpty ? '000000000000' : messagingSenderId,
        projectId: projectId,
        authDomain: authDomain.isEmpty ? null : authDomain,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
      ),
    );
    return;
  }
  await Firebase.initializeApp();
}
