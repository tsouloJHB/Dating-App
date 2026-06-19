import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_provider.dart';

/// On web, Google Sign-In uses GIS renderButton; completion is delivered on
/// GoogleSignIn.instance.authenticationEvents. Attaches one listener for the
/// app lifetime (watch from root UI after init).
final googleSignInWebAuthListenerProvider = Provider<void>((ref) {
  if (GoogleSignIn.instance.supportsAuthenticate()) return;

  late final StreamSubscription<GoogleSignInAuthenticationEvent> sub;
  sub = GoogleSignIn.instance.authenticationEvents.listen(
    (event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        unawaited(
          ref.read(authStateProvider.notifier).completeGoogleSignInWithAccount(
                event.user,
              ),
        );
      }
    },
    onError: (Object e, StackTrace st) {
      ref.read(authStateProvider.notifier).setGoogleSignInErrorFromPlatform(e);
    },
  );

  ref.onDispose(sub.cancel);
});
