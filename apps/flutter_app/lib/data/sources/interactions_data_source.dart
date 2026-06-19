import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';

/// Interaction response from server (LIKE / PASS).
class InteractionResponse {
  final bool ok;
  final String actorId;
  final String targetId;
  final String type;
  final bool matchCreated;

  InteractionResponse({
    required this.ok,
    required this.actorId,
    required this.targetId,
    required this.type,
    required this.matchCreated,
  });

  factory InteractionResponse.fromJson(Map<String, dynamic> json) {
    final interaction = json['interaction'] ?? {};
    return InteractionResponse(
      ok: json['ok'] == true,
      actorId: interaction['actorId'] ?? '',
      targetId: interaction['targetId'] ?? '',
      type: interaction['type'] ?? 'LIKE',
      matchCreated: interaction['matchCreated'] == true,
    );
  }
}

/// Interactions data source for swipe actions (LIKE / PASS).
class InteractionsDataSource {
  final Dio dio;

  InteractionsDataSource({required this.dio});

  /// Record a LIKE or PASS action.
  /// Returns true if a match was created (reciprocal LIKE).
  Future<InteractionResponse> recordInteraction({
    required String targetId,
    required String type, // 'LIKE' or 'PASS'
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.interactions,
        data: {
          'targetId': targetId,
          'type': type,
        },
      );

      if (response.statusCode == 200) {
        return InteractionResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to record interaction: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user's interactions (paginated).
  Future<Map<String, dynamic>> getMyInteractions({
    String? cursor,
    int limit = 8,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.interactions}/mine',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to fetch interactions: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
