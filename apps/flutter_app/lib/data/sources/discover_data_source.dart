import 'package:dio/dio.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/match_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';

abstract class DiscoverDataSource {
  Future<DiscoverPage> getProfilesForDiscovery({
    required String actorUserId,
    double? latitude,
    double? longitude,
    required int distanceKm,
    required int minAge,
    required int maxAge,
    required int limit,
    String? cursor,
  });

  Future<void> likeProfile(String targetUserId);

  Future<void> passProfile(String targetUserId);

  Future<List<Match>> getMatches();
}

class DiscoverPage {
  final List<User> profiles;
  final String? nextCursor;
  final int limit;

  const DiscoverPage({
    required this.profiles,
    required this.nextCursor,
    required this.limit,
  });
}

class DiscoverDataSourceImpl implements DiscoverDataSource {
  final Dio dio;

  DiscoverDataSourceImpl(this.dio);

  @override
  Future<DiscoverPage> getProfilesForDiscovery({
    required String actorUserId,
    double? latitude,
    double? longitude,
    required int distanceKm,
    required int minAge,
    required int maxAge,
    required int limit,
    String? cursor,
  }) async {
    if (actorUserId.trim().isEmpty) {
      throw ApiException(
        message: 'Your session is not ready. Please sign in again.',
        statusCode: 401,
        kind: ApiErrorKind.unauthorized,
      );
    }

    try {
      final response = await dio.post(
        ApiConstants.discoverProfiles,
        data: {
          'userId': actorUserId,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'distanceKm': distanceKm,
          'minAge': minAge,
          'maxAge': maxAge,
        },
      );

      final raw = response.data['profiles'];
      final profiles = (raw is List ? raw : const <dynamic>[])
          .map((p) => User.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();

      return DiscoverPage(
        profiles: profiles,
        nextCursor: response.data['nextCursor'] as String?,
        limit: (response.data['limit'] as num?)?.toInt() ?? limit,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> likeProfile(String targetUserId) async {
    try {
      await dio.post(
        ApiConstants.interactions,
        data: {'targetId': targetUserId, 'type': 'LIKE'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> passProfile(String targetUserId) async {
    try {
      await dio.post(
        ApiConstants.interactions,
        data: {'targetId': targetUserId, 'type': 'PASS'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<List<Match>> getMatches() async {
    try {
      final response = await dio.get(ApiConstants.matchesList);

      final raw = response.data['matches'];
      final matches = (raw is List ? raw : const <dynamic>[])
          .map((m) => Match.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList();

      return matches;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
