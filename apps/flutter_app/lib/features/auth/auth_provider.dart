import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/bootstrap/google_sign_in_bootstrap.dart'
    show
        isGoogleWebClientIdConfigured,
        missingGoogleClientIdUserMessage,
        rehydrateGoogleWebClientIdAndApplySignIn;
import '../../core/network/api_exception.dart';
import '../../core/network/auth_session_bridge.dart';
import '../../core/network/dio_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/sources/auth_data_source.dart';
import '../../domain/models/user_model.dart';

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw StateError('Dio not initialized'),
      );
  return AuthDataSourceImpl(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.bootstrapPending = false,
    this.profileSetupPending = false,
    this.profileSetupRoute,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool bootstrapPending;
  final bool profileSetupPending;
  /// When [profileSetupPending], user must stay on this route (e.g. `/sign-up` or `/google-profile-setup`).
  final String? profileSetupRoute;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? bootstrapPending,
    bool? profileSetupPending,
    String? profileSetupRoute,
    bool clearUser = false,
    bool clearError = false,
    bool clearProfileSetupRoute = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      bootstrapPending: bootstrapPending ?? this.bootstrapPending,
      profileSetupPending: profileSetupPending ?? this.profileSetupPending,
      profileSetupRoute: clearProfileSetupRoute
          ? null
          : (profileSetupRoute ?? this.profileSetupRoute),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.repository)
      : super(const AuthState(bootstrapPending: true)) {
    AuthSessionBridge.instance.onSessionExpired = _onSessionExpiredFromInterceptor;
    Future.microtask(_bootstrap);
  }

  final AuthRepository repository;

  void _onSessionExpiredFromInterceptor() {
    state = const AuthState(
      bootstrapPending: false,
      isAuthenticated: false,
    );
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        state = state.copyWith(bootstrapPending: false);
        return;
      }
      final user = await repository.getCurrentUser();
      final needsSetup = await repository.userRequiresProfileCompletion(user.id);
      state = AuthState(
        user: user,
        isAuthenticated: true,
        bootstrapPending: false,
        profileSetupPending: needsSetup,
        profileSetupRoute: needsSetup ? '/google-profile-setup' : null,
      );
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
      }
      state = state.copyWith(bootstrapPending: false);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      state = state.copyWith(bootstrapPending: false);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String sexualOrientation,
    required int age,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearUser: true,
      isAuthenticated: false,
      profileSetupPending: false,
      clearProfileSetupRoute: true,
    );
    try {
      final user = await repository.signUp(
        email: email,
        password: password,
        name: name,
        gender: gender,
        sexualOrientation: sexualOrientation,
        age: age,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        profileSetupPending: true,
        profileSetupRoute: '/sign-up',
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        profileSetupPending: false,
        clearProfileSetupRoute: true,
        error: _friendlyAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        profileSetupPending: false,
        clearProfileSetupRoute: true,
        error: 'Could not create account. Please try again.',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearUser: true,
      isAuthenticated: false,
      profileSetupPending: false,
      clearProfileSetupRoute: true,
    );
    try {
      final user = await repository.signIn(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        profileSetupPending: false,
        clearProfileSetupRoute: true,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        profileSetupPending: false,
        clearProfileSetupRoute: true,
        error: _friendlyAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        profileSetupPending: false,
        clearProfileSetupRoute: true,
        error: 'Could not sign in: $e',
      );
    }
  }

  /// Called when the Google Identity Services button completes on web (via authenticationEvents).
  Future<void> completeGoogleSignInWithAccount(GoogleSignInAccount account) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearUser: true,
      isAuthenticated: false,
      profileSetupPending: false,
      clearProfileSetupRoute: true,
    );
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      await rehydrateGoogleWebClientIdAndApplySignIn();
    }
    if (!isGoogleWebClientIdConfigured) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: missingGoogleClientIdUserMessage(),
      );
      return;
    }
    await _exchangeGoogleAccount(account);
  }

  void setGoogleSignInErrorFromPlatform(Object error) {
    state = state.copyWith(
      isLoading: false,
      clearUser: true,
      isAuthenticated: false,
      error: 'Could not complete Google sign-in: $error',
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearUser: true,
      isAuthenticated: false,
      profileSetupPending: false,
      clearProfileSetupRoute: true,
    );
    await rehydrateGoogleWebClientIdAndApplySignIn();
    if (!isGoogleWebClientIdConfigured) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: missingGoogleClientIdUserMessage(),
      );
      return;
    }
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      state = state.copyWith(isLoading: false);
      return;
    }
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['openid', 'email', 'profile'],
      );
      await _exchangeGoogleAccount(account);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        state = state.copyWith(isLoading: false, clearUser: true, isAuthenticated: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: e.description ?? e.toString(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: _friendlyGoogleAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: 'Could not complete Google sign-in: $e',
      );
    }
  }

  Future<void> _exchangeGoogleAccount(GoogleSignInAccount account) async {
    try {
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          clearUser: true,
          isAuthenticated: false,
          error:
              'Google did not return an ID token. Use the same OAuth Web client ID as your API: '
              'create assets/secrets/google_web_client_id.txt (one line, see assets/secrets/README.txt) '
              'or use --dart-define=GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com',
        );
        return;
      }

      String? accessToken;
      try {
        final authz = await account.authorizationClient.authorizationForScopes(
          const ['openid', 'email'],
        );
        accessToken = authz?.accessToken;
      } catch (_) {
        accessToken = null;
      }

      final user = await repository.signInWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );
      final needsSetup = await repository.userRequiresProfileCompletion(user.id);
      state = AuthState(
        user: user,
        isAuthenticated: true,
        bootstrapPending: false,
        profileSetupPending: needsSetup,
        profileSetupRoute: needsSetup ? '/google-profile-setup' : null,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: _friendlyGoogleAuthError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        isAuthenticated: false,
        error: 'Could not complete Google sign-in: $e',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Try to call logout API, but don't fail if it errors
      try {
        await repository.logout();
      } catch (e) {
        // Log the error but continue with logout
        print('[AuthProvider] Logout API error: $e');
      }

      // Always sign out from Google if signed in that way
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      // Clear local auth state regardless of API response
      state = const AuthState(bootstrapPending: false);
    } catch (e) {
      // Fallback: still clear state on unexpected errors
      print('[AuthProvider] Unexpected logout error: $e');
      state = const AuthState(bootstrapPending: false);
    }
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await repository.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        profileSetupPending: false,
        clearProfileSetupRoute: true,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void completeProfileSetup() {
    state = state.copyWith(
      profileSetupPending: false,
      clearProfileSetupRoute: true,
    );
  }

  @override
  void dispose() {
    if (AuthSessionBridge.instance.onSessionExpired == _onSessionExpiredFromInterceptor) {
      AuthSessionBridge.instance.onSessionExpired = null;
    }
    super.dispose();
  }

  String _friendlyGoogleAuthError(ApiException error) {
    final msg = error.message.toLowerCase();
    if (msg.contains('provider') && msg.contains('not')) {
      return 'Google sign-in is not enabled on the server yet. Add GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.';
    }
    if (msg.contains('invalid') && msg.contains('token')) {
      return 'Google could not verify your session. Check that the Web client ID matches the server.';
    }
    if (error.statusCode == 401) {
      return 'Google sign-in was rejected. Check OAuth client IDs and server configuration.';
    }
    return _friendlyAuthError(error);
  }

  String _friendlyAuthError(ApiException error) {
    if (error.isNetwork) {
      return 'No internet connection. Check your network and try again.';
    }
    if (error.kind == ApiErrorKind.timeout) {
      return 'Request timed out. Please try again.';
    }
    if (error.statusCode == 401) {
      return 'Incorrect email or password.';
    }
    if (error.statusCode == 409) {
      return 'This email is already registered. Try signing in.';
    }
    if (error.isRateLimited) {
      return 'Too many attempts. Please wait a moment and retry.';
    }
    if (error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
