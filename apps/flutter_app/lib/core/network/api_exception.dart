import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Typed API failure for global handling (401 / 403 / 429 / network).
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    required this.kind,
  });

  final String message;
  final int? statusCode;
  final ApiErrorKind kind;

  bool get isUnauthorized => kind == ApiErrorKind.unauthorized;
  bool get isForbidden => kind == ApiErrorKind.forbidden;
  bool get isRateLimited => kind == ApiErrorKind.rateLimited;
  bool get isNetwork => kind == ApiErrorKind.network;

  static ApiException fromDio(DioException e) {
    if (e.error is ApiException) {
      return e.error as ApiException;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timed out. Try again.',
          kind: ApiErrorKind.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: kDebugMode
              ? 'Cannot reach the API (${e.message ?? 'connection error'}). '
                  'Confirm the server is running, [Dio] baseUrl is correct, and '
                  'on Flutter web set server CORS_ORIGIN to this app’s origin '
                  '(exact URL in the address bar).'
              : 'No internet connection.',
          kind: ApiErrorKind.network,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Secure connection could not be verified.',
          kind: ApiErrorKind.network,
        );
      case DioExceptionType.badResponse:
        return _fromBadResponse(e);
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled.',
          kind: ApiErrorKind.unknown,
        );
      case DioExceptionType.unknown:
        return ApiException(
          message: e.message ?? 'Something went wrong.',
          kind: ApiErrorKind.unknown,
        );
    }
  }

  static ApiException _fromBadResponse(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    var bodyMessage = '';
    if (data is Map) {
      final err = data['error'];
      final msg = data['message'];
      if (err is String && err.isNotEmpty) {
        bodyMessage = err;
      } else if (msg is String && msg.isNotEmpty) {
        bodyMessage = msg;
      }
    }

    if (code == 401) {
      return ApiException(
        message: bodyMessage.isNotEmpty ? bodyMessage : 'Session expired. Sign in again.',
        statusCode: code,
        kind: ApiErrorKind.unauthorized,
      );
    }
    if (code == 403) {
      return ApiException(
        message: bodyMessage.isNotEmpty ? bodyMessage : 'Premium or permission required.',
        statusCode: code,
        kind: ApiErrorKind.forbidden,
      );
    }
    if (code == 429) {
      return ApiException(
        message: 'Too many requests. Wait a moment and try again.',
        statusCode: code,
        kind: ApiErrorKind.rateLimited,
      );
    }

    return ApiException(
      message: bodyMessage.isNotEmpty
          ? bodyMessage
          : (e.response?.statusMessage ?? 'Request failed (${code ?? "?"})'),
      statusCode: code,
      kind: ApiErrorKind.server,
    );
  }

  @override
  String toString() => message;
}

enum ApiErrorKind {
  unauthorized,
  forbidden,
  rateLimited,
  network,
  timeout,
  server,
  unknown,
}
