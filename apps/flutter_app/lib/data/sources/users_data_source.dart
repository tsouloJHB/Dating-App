import 'package:dio/dio.dart';

/// User profile detail from GET /api/users/:userId.
class UserProfile {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Viewer already sent LIKE to this profile (from GET /api/users/:id).
  final bool viewerHasLiked;
  /// Mutual match exists between viewer and this profile.
  final bool hasMatch;
  /// Great-circle distance in km when both have coordinates; otherwise null.
  final double? distanceKm;

  UserProfile({
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
    required this.createdAt,
    required this.updatedAt,
    this.viewerHasLiked = false,
    this.hasMatch = false,
    this.distanceKm,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final photoUrlsRaw = json['photoUrls'];
    final photoUrls = photoUrlsRaw is List
        ? List<String>.from(photoUrlsRaw.map((x) => x.toString()))
        : <String>[];

    final distanceRaw = json['distanceKm'];
    return UserProfile(
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
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      viewerHasLiked: json['viewerHasLiked'] == true,
      hasMatch: json['hasMatch'] == true,
      distanceKm: distanceRaw is num ? distanceRaw.toDouble() : null,
    );
  }
}

/// Users data source (profile detail, profile view logging).
class UsersDataSource {
  final Dio dio;

  UsersDataSource({required this.dio});

  /// Get public profile of a user.
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await dio.get('/api/users/$userId');

      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Log that the current user viewed another user's profile.
  Future<void> logProfileView(String profileUserId) async {
    try {
      final response = await dio.post('/api/users/$profileUserId/views');

      if (response.statusCode != 200) {
        throw Exception('Failed to log profile view: ${response.statusCode}');
      }
    } catch (e) {
      // Non-critical; log but don't throw
      print('Warning: profile view logging failed: $e');
    }
  }
}
