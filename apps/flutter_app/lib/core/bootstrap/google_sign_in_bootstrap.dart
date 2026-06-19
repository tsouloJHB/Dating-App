import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_sign_in/google_sign_in.dart';

const _assetPath = 'assets/secrets/google_web_client_id.txt';

String _googleWebClientId = '';
String? _lastRehydrationKey;

/// True after a valid Web OAuth client id is resolved.
bool get isGoogleWebClientIdConfigured => _googleWebClientId.isNotEmpty;

/// Normalizes a line from the secrets file (quotes, BOM).
String normalizeWebClientIdLine(String line) {
  var t = line.trim();
  if (t.startsWith('\uFEFF')) {
    t = t.substring(1).trim();
  }
  if ((t.startsWith('"') && t.endsWith('"')) ||
      (t.startsWith("'") && t.endsWith("'"))) {
    t = t.substring(1, t.length - 1).trim();
  }
  return t;
}

/// Typical format: `123456789012-abc...xyz.apps.googleusercontent.com`
bool isValidWebClientId(String? raw) {
  final t = normalizeWebClientIdLine(raw ?? '');
  if (t.isEmpty) return false;
  final u = t.toUpperCase();
  // Avoid rejecting real IDs that accidentally contain substrings like "HERE".
  for (final bad in ['PASTE_', 'YOUR_WEB', 'REPLACE_', 'TODO:']) {
    if (u.contains(bad)) return false;
  }
  if (u.contains('PASTE') && u.contains('CLIENT')) return false;
  if (t.length < 40) return false;
  if (!t.contains('-')) return false;
  if (!t.endsWith('.apps.googleusercontent.com')) return false;
  return true;
}

Future<String> _readClientIdString() async {
  const fromEnv = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  if (fromEnv.trim().isNotEmpty && !isValidWebClientId(fromEnv)) {
    if (kDebugMode) {
      debugPrint(
        'google_sign_in_bootstrap: GOOGLE_WEB_CLIENT_ID is set at compile time '
        'but failed validation — falling back to $_assetPath',
      );
    }
  }
  if (isValidWebClientId(fromEnv)) {
    if (kDebugMode) {
      debugPrint(
        'google_sign_in_bootstrap: using Web client id from '
        '--dart-define=GOOGLE_WEB_CLIENT_ID (overrides the asset file).',
      );
    }
    return normalizeWebClientIdLine(fromEnv);
  }
  String parseClientId(String fileRaw, String sourcePath) {
    var foundInvalidNonCommentLine = false;
    for (final line in fileRaw.split(RegExp(r'\r?\n'))) {
      final stripped = line.trim();
      if (stripped.isEmpty || stripped.startsWith('#')) continue;
      final t = normalizeWebClientIdLine(stripped);
      if (isValidWebClientId(t)) {
        if (kDebugMode) {
          debugPrint(
            'google_sign_in_bootstrap: loaded Web client id from $sourcePath',
          );
        }
        return t;
      }
      foundInvalidNonCommentLine = true;
    }
    if (kDebugMode && foundInvalidNonCommentLine) {
      debugPrint(
        'google_sign_in_bootstrap: $sourcePath has non-comment lines but none '
        'passed validation (expect *.apps.googleusercontent.com, no placeholders).',
      );
    }
    return '';
  }

  Future<String> tryLoadFromPath(String path) async {
    try {
      final fileRaw = await rootBundle.loadString(path);
      return parseClientId(fileRaw, path);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('google_sign_in_bootstrap: could not load $path: $e\n$st');
      }
      return '';
    }
  }

  final fromPrimaryPath = await tryLoadFromPath(_assetPath);
  if (fromPrimaryPath.isNotEmpty) {
    return fromPrimaryPath;
  }

  // Some web-server/dev flows resolve project assets under `assets/assets/...`.
  if (kIsWeb) {
    const webNestedAssetPath = 'assets/assets/secrets/google_web_client_id.txt';
    if (webNestedAssetPath != _assetPath) {
      final fromWebNestedPath = await tryLoadFromPath(webNestedAssetPath);
      if (fromWebNestedPath.isNotEmpty) {
        return fromWebNestedPath;
      }
    }
  }
  return '';
}

Future<void> _applySignInFromResolvedId() async {
  final id = _googleWebClientId;
  if (kIsWeb) {
    if (id.isNotEmpty) {
      try {
        await GoogleSignIn.instance.initialize(clientId: id);
      } catch (_) {
        if (kDebugMode) {
          // Re-init on web if config changes — full reload may be needed.
        }
      }
    } else {
      try {
        await GoogleSignIn.instance.initialize();
      } catch (_) {}
    }
    return;
  }
  if (id.isNotEmpty) {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await GoogleSignIn.instance.initialize(serverClientId: id);
    } catch (_) {
      if (kDebugMode) {
        // "init already called" is OK if id already applied; else cold restart.
      }
    }
  } else {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (_) {}
  }
}

/// Reloads id from --dart-define + asset, then reconfigures the plugin.
Future<void> rehydrateGoogleWebClientIdAndApplySignIn() async {
  _googleWebClientId = await _readClientIdString();
  if (_lastRehydrationKey == _googleWebClientId) {
    return;
  }
  _lastRehydrationKey = _googleWebClientId;
  await _applySignInFromResolvedId();
}

Future<void> preloadGoogleWebClientId() async {
  _googleWebClientId = await _readClientIdString();
  _lastRehydrationKey = _googleWebClientId;
}

Future<void> ensureGoogleSignInInitialized() async {
  await rehydrateGoogleWebClientIdAndApplySignIn();
}

String missingGoogleClientIdUserMessage() =>
    'Configure Google OAuth 2.0 Web client ID (must match API GOOGLE_CLIENT_ID).\n\n'
    '• File assets/secrets/google_web_client_id.txt in this Flutter package: one '
    'non-comment line, no quotes around the id.\n'
    '• Passing --dart-define=GOOGLE_WEB_CLIENT_ID=... when you build overrides that '
    'file — fix or remove the define, then rebuild.\n'
    '• Run flutter clean && flutter pub get from this package root, then stop and '
    'start the app (hot reload does not reload assets).\n'
    '• Web: hard-refresh the browser after a new build.\n\n'
    'In debug, check console for lines starting with google_sign_in_bootstrap:';
