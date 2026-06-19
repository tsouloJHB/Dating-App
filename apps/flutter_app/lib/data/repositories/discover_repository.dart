import '../sources/discover_data_source.dart';
import '../../domain/models/match_model.dart';

abstract class DiscoverRepository {
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

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverDataSource dataSource;

  DiscoverRepositoryImpl(this.dataSource);

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
  }) =>
      dataSource.getProfilesForDiscovery(
        actorUserId: actorUserId,
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm,
        minAge: minAge,
        maxAge: maxAge,
        limit: limit,
        cursor: cursor,
      );

  @override
  Future<void> likeProfile(String targetUserId) =>
      dataSource.likeProfile(targetUserId);

  @override
  Future<void> passProfile(String targetUserId) =>
      dataSource.passProfile(targetUserId);

  @override
  Future<List<Match>> getMatches() => dataSource.getMatches();
}
