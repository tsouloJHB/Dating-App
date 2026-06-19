import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/sources/activity_data_source.dart';
import '../../data/sources/inbox_data_source.dart';
import '../../data/sources/matches_data_source.dart';
import '../../domain/models/user_model.dart';
import '../../core/network/dio_provider.dart';
import '../chat/chat_provider.dart';

// Activity Repository Providers
final activityDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return ActivityDataSourceImpl(dio);
});

final activityRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(activityDataSourceProvider);
  return ActivityRepositoryImpl(dataSource);
});

// Inbox Data Source Providers
final inboxDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return InboxDataSource(dio: dio);
});

final matchesDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return MatchesDataSource(dio: dio);
});

// Activity Providers
final whoLikedMeProvider = FutureProvider<List<User>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getWhoLikedMe();
});

final visitorsProvider = FutureProvider<List<User>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getVisitors();
});

// Inbox providers (who liked me — paginated with InboxUser model)
final likesInProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, cursor) async {
  final dataSource = ref.watch(inboxDataSourceProvider);
  return dataSource.getLikesIn(cursor: cursor);
});

// Visitors providers (profile visitors — paginated with InboxUser model)
final visitorsListProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, cursor) async {
  final dataSource = ref.watch(inboxDataSourceProvider);
  return dataSource.getVisitors(cursor: cursor);
});

final myLikesListProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, cursor) async {
  final dataSource = ref.watch(inboxDataSourceProvider);
  return dataSource.getMyLikes(cursor: cursor);
});

// Matches providers (mutual likes — paginated)
final matchesListProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, cursor) async {
  final dataSource = ref.watch(matchesDataSourceProvider);
  return dataSource.getMatches(cursor: cursor);
});

extension InboxMatchCacheInvalidation on WidgetRef {
  /// Refetch inbox / matches / threads after a LIKE or when Activity refresh is pressed.
  void invalidateInboxMatchCaches() {
    invalidate(likesInProvider);
    invalidate(visitorsListProvider);
    invalidate(matchesListProvider);
    invalidate(myLikesListProvider);
    invalidate(messageThreadsProvider);
  }
}
