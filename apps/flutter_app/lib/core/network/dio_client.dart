import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';
import 'auth_session_bridge.dart';

class DioClient {
  static final Dio _dio = Dio();

  static Future<Dio> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _dio.options.baseUrl = ApiConstants.baseUrl;
    if (kDebugMode) {
      final source = ApiConstants.hasApiBaseUrlOverride
          ? 'dart-define(API_BASE_URL)'
          : 'ENVIRONMENT defaults';
      debugPrint('[Dio] environment=${ApiConstants.environment}');
      debugPrint('[Dio] baseUrl=${ApiConstants.baseUrl} (source=$source)');
      if (kIsWeb) {
        debugPrint(
          '[Dio] Web app origin (set Worker CORS_ORIGIN to this exact value): '
          '${Uri.base.origin}',
        );
      }
    }
    _dio.options.connectTimeout = HttpConfig.connectionTimeout;
    _dio.options.receiveTimeout = HttpConfig.receiveTimeout;
    _dio.options.contentType = 'application/json';
    
    // Setup cookie jar for session management (Better Auth uses httpOnly session cookies)
    // This replaces manual Bearer token handling - cookies are automatically managed
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(storage: FileStorage('${appDocDir.path}/cookies'));
    
    _dio.interceptors
      ..clear()
      ..add(MobileOriginInterceptor())
      ..add(BearerTokenInterceptor(prefs))
      ..add(CookieManager(cookieJar))
      ..add(ErrorInterceptor());

    if (kDebugMode) {
      debugPrint('[DioClient] ✓ Initialized with session cookie management (Better Auth compatible)');
    }

    return _dio;
  }

  static Dio getInstance() => _dio;
}

class BearerTokenInterceptor extends Interceptor {
  BearerTokenInterceptor(this.prefs);

  final SharedPreferences prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = prefs.getString('auth_token');
    if (kDebugMode) {
      debugPrint(
        '[BearerTokenInterceptor] ${options.method} ${options.path} token=${token == null ? 'missing' : 'present(${token.length})'}',
      );
    }
    if (token != null && token.isNotEmpty && options.headers['Authorization'] == null) {
      options.headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        debugPrint('[BearerTokenInterceptor] Authorization header attached');
      }
    }
    handler.next(options);
  }
}

class MobileOriginInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Better Auth expects an Origin on certain auth routes.
    // dart:io clients (Flutter mobile) usually omit it, so set a stable value.
    if (!kIsWeb && options.headers['Origin'] == null) {
      options.headers['Origin'] = ApiConstants.baseUrl;
    }
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final api = err.error is ApiException
        ? err.error as ApiException
        : ApiException.fromDio(err);

    final path = err.requestOptions.path.toLowerCase();

    // Avoid force-logout on every protected endpoint 401.
    // Only propagate session-expired signal for explicit session probe failures.
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('[ErrorInterceptor] 401 Unauthorized on ${err.requestOptions.path}');
      }
      // Sign-in / sign-up / social-auth paths legitimately return 401 for
      // wrong credentials — don't treat those as session expiry.
      final isCredentialError = path.contains('/api/auth/sign-in') ||
          path.contains('/api/auth/sign-up') ||
          path.contains('/api/auth/callback') ||
          path.contains('/api/auth/social');
      if (!isCredentialError) {
        AuthSessionBridge.instance.notifySessionExpired();
      }
    }

    if (kDebugMode) {
      debugPrint('[Dio] ${api.kind} ${api.statusCode ?? ''}: ${api.message}');
    }

    final nextErr = err.error is ApiException ? err : err.copyWith(error: api);
    handler.next(nextErr);
  }
}
