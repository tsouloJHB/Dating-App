import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';
import 'auth_session_bridge.dart';

class DioClient {
  static final Dio _dio = Dio();

  static Future<Dio> initialize() async {
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
      ..add(CookieManager(cookieJar))
      ..add(ErrorInterceptor());

    if (kDebugMode) {
      debugPrint('[DioClient] ✓ Initialized with session cookie management (Better Auth compatible)');
    }

    return _dio;
  }

  static Dio getInstance() => _dio;
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final api = err.error is ApiException
        ? err.error as ApiException
        : ApiException.fromDio(err);

    // Handle 401 by notifying session expiration (cookies will be cleared by cookie jar)
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('[ErrorInterceptor] 401 Unauthorized - session expired');
      }
      AuthSessionBridge.instance.notifySessionExpired();
    }

    if (kDebugMode) {
      debugPrint('[Dio] ${api.kind} ${api.statusCode ?? ''}: ${api.message}');
    }

    final nextErr = err.error is ApiException ? err : err.copyWith(error: api);
    handler.next(nextErr);
  }
}
