import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('[Dio] baseUrl=${ApiConstants.baseUrl}');
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

    _dio.interceptors
      ..clear()
      ..add(AuthInterceptor(prefs))
      ..add(ErrorInterceptor());

    return _dio;
  }

  static Dio getInstance() => _dio;
}

bool _shouldClearTokenOn401(String path) {
  final p = path.toLowerCase();
  if (p.contains('sign-in') || p.contains('sign-up')) {
    return false;
  }
  return true;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.prefs);

  final SharedPreferences prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final code = err.response?.statusCode;
    if (code == 401 &&
        _shouldClearTokenOn401(err.requestOptions.path)) {
      await prefs.remove('auth_token');
      AuthSessionBridge.instance.notifySessionExpired();
    }
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final api = err.error is ApiException
        ? err.error as ApiException
        : ApiException.fromDio(err);

    if (kDebugMode) {
      debugPrint('[Dio] ${api.kind} ${api.statusCode ?? ''}: ${api.message}');
    }

    final nextErr = err.error is ApiException ? err : err.copyWith(error: api);
    handler.next(nextErr);
  }
}
