import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../domain/models/user_model.dart';

abstract class AuthDataSource {
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String sexualOrientation,
    required int age,
  });

  Future<User> signIn({
    required String email,
    required String password,
  });

  /// Better Auth Google provider using an ID token from `google_sign_in`.
  Future<User> signInWithGoogle({
    required String idToken,
    String? accessToken,
  });

  /// Uses [GET /api/users/:id] — incomplete if photos, gender, or orientation are missing.
  Future<bool> userRequiresProfileCompletion(String userId);

  Future<void> logout();

  Future<User> getCurrentUser();
}

class AuthDataSourceImpl implements AuthDataSource {
  AuthDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,
    required String sexualOrientation,
    required int age,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        ApiConstants.authSignUp,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      final payload = _asAuthResponseMapOrThrow(
        response,
        endpoint: ApiConstants.authSignUp,
      );

      await _persistAuthFromResponse(response);
      await _completeSignupProfile(
        gender: gender,
        sexualOrientation: sexualOrientation,
      );
      final responseUser = _extractUserFromAuthResponse(payload);
      if (responseUser != null) {
        return responseUser.copyWith(
          gender: gender,
          sexualOrientation: sexualOrientation,
          age: age,
        );
      }
      final currentUser = await getCurrentUser();
      return currentUser.copyWith(
        gender: currentUser.gender.isEmpty ? gender : currentUser.gender,
        sexualOrientation: currentUser.sexualOrientation.isEmpty
            ? sexualOrientation
            : currentUser.sexualOrientation,
        age: currentUser.age == 18 ? age : currentUser.age,
      );
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  @override
  Future<User> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        ApiConstants.authSignInSocial,
        data: {
          'provider': 'google',
          'idToken': {
            'token': idToken,
            if (accessToken != null && accessToken.isNotEmpty) 'accessToken': accessToken,
          },
        },
      );
      _asAuthResponseMapOrThrow(
        response,
        endpoint: ApiConstants.authSignInSocial,
      );

      await _persistAuthFromResponse(response);
      final responseUser = _extractUserFromAuthResponse(response.data);
      if (responseUser != null) {
        return responseUser;
      }
      return await getCurrentUser();
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  @override
  Future<bool> userRequiresProfileCompletion(String userId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.userProfile(userId),
      );
      final data = response.data ?? <String, dynamic>{};
      final photosRaw = data['photoUrls'];
      final photos = photosRaw is List ? photosRaw : const <dynamic>[];
      final hasPhoto = photos.any(
        (e) => e != null && e.toString().trim().isNotEmpty,
      );
      final gender = (data['gender'] ?? '').toString().trim();
      final orientation = (data['sexualOrientation'] ?? '').toString().trim();
      return !hasPhoto || gender.isEmpty || orientation.isEmpty;
    } on DioException catch (e) {
      final ex = _asApiException(e);
      // A 404 means the profile row doesn't exist yet — treat as incomplete.
      if (ex.statusCode == 404) return true;
      throw ex;
    }
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        ApiConstants.authSignIn,
        data: {
          'email': email,
          'password': password,
        },
      );
      final payload = _asAuthResponseMapOrThrow(
        response,
        endpoint: ApiConstants.authSignIn,
      );

      await _persistAuthFromResponse(response);
      final responseUser = _extractUserFromAuthResponse(payload);
      if (responseUser != null) {
        return responseUser;
      }
      return await getCurrentUser();
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.authLogout);
    } on DioException catch (e) {
      throw _asApiException(e);
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(ApiConstants.authSession);
      final sessionPayload = response.data ?? <String, dynamic>{};
      final directUser = sessionPayload['user'] as Map<String, dynamic>?;
      final nestedUser = (sessionPayload['session'] as Map<String, dynamic>?)?['user']
          as Map<String, dynamic>?;
      final sessionUser = directUser ?? nestedUser;

      if (sessionUser == null) {
        throw ApiException(
          message: 'No active session.',
          statusCode: 401,
          kind: ApiErrorKind.unauthorized,
        );
      }

      return _mapSessionUserToDomain(sessionUser);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  ApiException _asApiException(DioException e) {
    if (e.error is ApiException) {
      return e.error as ApiException;
    }
    return ApiException.fromDio(e);
  }

  Map<String, dynamic> _asAuthResponseMapOrThrow(
    Response<dynamic> response, {
    required String endpoint,
  }) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw ApiException(
      message:
          'Server returned an unexpected response for $endpoint. '
          'Check that API_BASE_URL points to the JustHookups API worker.',
      statusCode: response.statusCode,
      kind: ApiErrorKind.server,
    );
  }

  Future<void> _completeSignupProfile({
    required String gender,
    required String sexualOrientation,
  }) async {
    await dio.put(
      ApiConstants.accountProfile,
      data: {
        'bio': '',
        'gender': gender,
        'preferredGender': sexualOrientation,
      },
    );
  }

  Future<void> _persistAuthFromResponse(Response<dynamic> response) async {
    final headerToken = _readSetAuthToken(response);
    final data = response.data;
    final bodyToken = data == null
        ? null
        : _firstString([
            data['token'],
            data['accessToken'],
            data['bearerToken'],
            (data['session'] as Map<String, dynamic>?)?['token'],
          ]);

    final token = (headerToken != null && headerToken.isNotEmpty)
        ? headerToken
        : bodyToken;

    if (token == null || token.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  String? _readSetAuthToken(Response response) {
    final headers = response.headers;
    final direct = headers.value('set-auth-token');
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    for (final e in headers.map.entries) {
      if (e.key.toLowerCase() == 'set-auth-token' && e.value.isNotEmpty) {
        return e.value.first;
      }
    }
    return null;
  }

  String? _firstString(List<dynamic> values) {
    for (final v in values) {
      if (v is String && v.isNotEmpty) {
        return v;
      }
    }
    return null;
  }

  User? _extractUserFromAuthResponse(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    final directUser = data['user'] as Map<String, dynamic>?;
    final nestedUser =
        (data['session'] as Map<String, dynamic>?)?['user'] as Map<String, dynamic>?;
    final authUser = directUser ?? nestedUser;

    if (authUser == null) {
      return null;
    }

    return _mapSessionUserToDomain(authUser);
  }

  User _mapSessionUserToDomain(Map<String, dynamic> sessionUser) {
    final createdAtRaw = sessionUser['createdAt']?.toString();
    final updatedAtRaw = sessionUser['updatedAt']?.toString();
    final imageUrl = sessionUser['image']?.toString();
    final photoUrls = (sessionUser['photoUrls'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e.toString())
        .toList();

    if (photoUrls.isEmpty && imageUrl != null && imageUrl.isNotEmpty) {
      photoUrls.add(imageUrl);
    }

    return User(
      id: sessionUser['id']?.toString() ?? '',
      email: sessionUser['email']?.toString() ?? '',
      name: sessionUser['name']?.toString() ?? '',
      gender: sessionUser['gender']?.toString() ?? '',
      sexualOrientation: sessionUser['sexualOrientation']?.toString() ?? '',
      age: (sessionUser['age'] as num?)?.toInt() ?? 18,
      latitude: (sessionUser['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (sessionUser['longitude'] as num?)?.toDouble() ?? 0,
      photoUrls: photoUrls,
      bio: sessionUser['bio']?.toString(),
      isPremium: sessionUser['isPremium'] == true,
      createdAt: DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAtRaw ?? '') ?? DateTime.now(),
    );
  }
}
