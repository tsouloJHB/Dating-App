import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import 'inbox_data_source.dart';

/// Matches data source (mutual likes).
class MatchesDataSource {
  final Dio dio;

  MatchesDataSource({required this.dio});

  /// Get current user's matches (mutual likes).
  Future<Map<String, dynamic>> getMatches({
    String? cursor,
    int limit = 8,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.matchesList,
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'matches': (data['matches'] as List?)
                  ?.map((u) => InboxUser.fromJson(u as Map<String, dynamic>))
                  .toList() ??
              [],
          'nextCursor': data['nextCursor'],
          'limit': data['limit'] ?? limit,
        };
      } else {
        throw Exception('Failed to fetch matches: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
