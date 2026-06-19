import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';

/// User profile from inbox/matches endpoints.
class InboxUser {
  final String id;
  final String email;
  final String name;
  final String gender;
  final String sexualOrientation;
  final int age;
  final double latitude;
  final double longitude;
  final List<String> photoUrls;
  final String? bio;
  final bool isPremium;
  final String? eventTime; // likedAt, viewedAt, matchedAt

  InboxUser({
    required this.id,
    required this.email,
    required this.name,
    required this.gender,
    required this.sexualOrientation,
    required this.age,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
    this.bio,
    required this.isPremium,
    this.eventTime,
  });

  factory InboxUser.fromJson(Map<String, dynamic> json) {
    final photoUrlsRaw = json['photoUrls'];
    final photoUrls = photoUrlsRaw is List
        ? List<String>.from(photoUrlsRaw.map((x) => x.toString()))
        : <String>[];

    return InboxUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      sexualOrientation: json['sexualOrientation'] ?? '',
      age: json['age'] ?? 18,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      photoUrls: photoUrls,
      bio: json['bio'],
      isPremium: json['isPremium'] == true,
      eventTime: json['likedAt'] ?? json['viewedAt'] ?? json['matchedAt'],
    );
  }
}

/// Inbox data source (who liked me, profile visitors).
class InboxDataSource {
  final Dio dio;

  InboxDataSource({required this.dio});

  /// Get profiles that liked the current user.
  Future<Map<String, dynamic>> getLikesIn({
    String? cursor,
    int limit = 8,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.activityWhoLikedMe,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'users': (data['users'] as List?)
                  ?.map((u) => InboxUser.fromJson(u as Map<String, dynamic>))
                  .toList() ??
              [],
          'nextCursor': data['nextCursor'],
          'limit': data['limit'] ?? limit,
        };
      } else {
        throw Exception('Failed to fetch likes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get profiles that visited the current user.
  Future<Map<String, dynamic>> getVisitors({
    String? cursor,
    int limit = 8,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.activityVisitors,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'users': (data['users'] as List?)
                  ?.map((u) => InboxUser.fromJson(u as Map<String, dynamic>))
                  .toList() ??
              [],
          'nextCursor': data['nextCursor'],
          'limit': data['limit'] ?? limit,
        };
      } else {
        throw Exception('Failed to fetch visitors: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get profiles the current user has liked.
  Future<Map<String, dynamic>> getMyLikes({
    String? cursor,
    int limit = 8,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.interactionsLikesOut,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'users': (data['users'] as List?)
                  ?.map((u) => InboxUser.fromJson(u as Map<String, dynamic>))
                  .toList() ??
              [],
          'nextCursor': data['nextCursor'],
          'limit': data['limit'] ?? limit,
        };
      } else {
        throw Exception('Failed to fetch my likes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
