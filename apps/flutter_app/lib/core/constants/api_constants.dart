import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Production default when not in debug (and no override).
  static const String _productionBaseUrl = 'https://api.justhookups.dev';

  /// Resolved API origin.
  ///
  /// Override for any platform:
  /// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8787`
  ///
  /// Debug defaults:
  /// - **Web:** `http://localhost:8787` (Wrangler dev; ensure `CORS_ORIGIN` on
  ///   the server matches the exact origin in the browser address bar).
  /// - **Android emulator:** `http://10.0.2.2:8787` (host loopback).
  /// - **Other:** `http://localhost:8787`.
  ///
  /// Physical device: use your machine’s LAN IP, e.g.
  /// `--dart-define=API_BASE_URL=http://192.168.1.10:8787`.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kDebugMode) {
      if (kIsWeb) return 'http://localhost:8787';
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:8787';
      }
      return 'http://localhost:8787';
    }
    return _productionBaseUrl;
  }
  
  // Auth Endpoints
  static const String authSignUp = '/api/auth/sign-up/email';
  static const String authSignIn = '/api/auth/sign-in/email';
  static const String authSignInSocial = '/api/auth/sign-in/social';
  static const String authLogout = '/api/auth/sign-out';
  static const String authSession = '/api/auth/get-session';
  
  // Discovery Endpoints
  static const String discoverProfiles = '/api/discover';
  
  // Interactions Endpoints
  static const String interactions = '/api/interactions';
  static const String interactionsLikesOut = '/api/interactions/likes-out';
  
  // Activity Endpoints
  static const String activityWhoLikedMe = '/api/inbox/likes-in';
  static const String activityVisitors = '/api/inbox/visitors';
  
  // Matches Endpoints
  static const String matchesList = '/api/matches';
  
  // Messages — list at /threads; history and send use /api/messages/:threadId
  static const String messagesThreads = '/api/messages/threads';

  static String messagesHistory(String threadId) =>
      '/api/messages/${Uri.encodeComponent(threadId)}';

  static String messagesSend(String threadId) =>
      '/api/messages/${Uri.encodeComponent(threadId)}';
  
  // Media Endpoints
  static const String mediaUpload = '/api/media/upload';
  static const String mediaReorder = '/api/media/reorder';

  static String mediaItem(String id) =>
      '/api/media/item/${Uri.encodeComponent(id)}';

  // Account Endpoints
  static const String accountProfile = '/api/account/profile';
  static const String accountSettings = '/api/account/settings';
  static const String accountUser = '/api/account/user';
  static const String accountOnboardingComplete = '/api/account/onboarding/complete';
  static const String accountHide = '/api/account/hide';
  static const String accountDelete = '/api/account';

  // Users (public profiles)
  static String userProfile(String userId) => '/api/users/${Uri.encodeComponent(userId)}';
  
  // Billing Endpoints
  static const String billingSubscriptions = '/api/billing/subscriptions';
  static const String billingVerify = '/api/billing/verify';
}

class HttpConfig {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
