import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../data/sources/interactions_data_source.dart';

/// Interactions data source provider.
final interactionsDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return InteractionsDataSource(dio: dio);
});

/// Record a swipe action (LIKE or PASS) — does not throw, returns response.
final recordInteractionProvider = FutureProvider.family<bool, ({String targetId, String type})>((ref, params) async {
  final dataSource = ref.watch(interactionsDataSourceProvider);
  final response = await dataSource.recordInteraction(
    targetId: params.targetId,
    type: params.type,
  );
  return response.matchCreated;
});

/// Get current user's interaction history.
final myInteractionsProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, cursor) async {
  final dataSource = ref.watch(interactionsDataSourceProvider);
  return dataSource.getMyInteractions(cursor: cursor);
});
