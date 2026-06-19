import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/discover_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/sources/discover_data_source.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/match_model.dart';
import '../../core/network/dio_provider.dart';
import '../../core/services/location_service.dart';
import '../profile/profile_provider.dart';

// Discover Repository Providers
final discoverDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return DiscoverDataSourceImpl(dio);
});

final discoverRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(discoverDataSourceProvider);
  return DiscoverRepositoryImpl(dataSource);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

// Discover State Providers
final discoverStateProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  final repository = ref.watch(discoverRepositoryProvider);
  return DiscoverNotifier(repository);
});

// Matches Provider
final matchesProvider = FutureProvider<List<Match>>((ref) {
  final repository = ref.watch(discoverRepositoryProvider);
  return repository.getMatches();
});

class DiscoverState {
  final List<User> profiles;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<String> seenProfileIds; // Track swiped profiles
  final int currentIndex;
  final String? nextCursor;
  final bool hasMore;
  final int distanceKm;
  final int minAge;
  final int maxAge;
  final double? latitude;
  final double? longitude;

  DiscoverState({
    this.profiles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.seenProfileIds = const [],
    this.currentIndex = 0,
    this.nextCursor,
    this.hasMore = true,
    this.distanceKm = 50,
    this.minAge = 18,
    this.maxAge = 80,
    this.latitude,
    this.longitude,
  });

  DiscoverState copyWith({
    List<User>? profiles,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<String>? seenProfileIds,
    int? currentIndex,
    String? nextCursor,
    bool? hasMore,
    int? distanceKm,
    int? minAge,
    int? maxAge,
    double? latitude,
    double? longitude,
    bool clearError = false,
  }) {
    return DiscoverState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      seenProfileIds: seenProfileIds ?? this.seenProfileIds,
      currentIndex: currentIndex ?? this.currentIndex,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      distanceKm: distanceKm ?? this.distanceKm,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class DiscoverLocationState {
  final bool isLoading;
  final double? latitude;
  final double? longitude;
  final bool hasPermission;
  final String? error;

  const DiscoverLocationState({
    this.isLoading = false,
    this.latitude,
    this.longitude,
    this.hasPermission = false,
    this.error,
  });

  DiscoverLocationState copyWith({
    bool? isLoading,
    double? latitude,
    double? longitude,
    bool? hasPermission,
    String? error,
    bool clearError = false,
  }) {
    return DiscoverLocationState(
      isLoading: isLoading ?? this.isLoading,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasPermission: hasPermission ?? this.hasPermission,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final discoverLocationProvider =
    StateNotifierProvider<DiscoverLocationNotifier, DiscoverLocationState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  return DiscoverLocationNotifier(locationService, profileRepository);
});

class DiscoverLocationNotifier extends StateNotifier<DiscoverLocationState> {
  final LocationService _locationService;
  final ProfileRepository _profileRepository;

  DiscoverLocationNotifier(this._locationService, this._profileRepository)
      : super(const DiscoverLocationState());

  Future<LocationData?> refresh({bool syncToBackend = true}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (location?.latitude == null || location?.longitude == null) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: 'Location unavailable',
        );
        return null;
      }

      state = state.copyWith(
        isLoading: false,
        hasPermission: true,
        latitude: location!.latitude,
        longitude: location.longitude,
      );

      if (syncToBackend) {
        await _profileRepository.syncLocation(
          latitude: location.latitude!,
          longitude: location.longitude!,
        );
      }

      return location;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
}

class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final DiscoverRepository repository;

  DiscoverNotifier(this.repository) : super(DiscoverState());

  void updateFilters({
    required int distanceKm,
    required int minAge,
    required int maxAge,
  }) {
    state = state.copyWith(
      distanceKm: distanceKm,
      minAge: minAge,
      maxAge: maxAge,
    );
  }

  void updateLocation({double? latitude, double? longitude}) {
    state = state.copyWith(latitude: latitude, longitude: longitude);
  }

  Future<void> fetchProfiles({
    required String actorUserId,
    double? latitude,
    double? longitude,
    int? distanceKm,
    int? minAge,
    int? maxAge,
    String? cursor,
    bool append = false,
  }) async {
    if (append) {
      if (state.isLoadingMore || !state.hasMore) return;
      state = state.copyWith(isLoadingMore: true, clearError: true);
    } else {
      state = state.copyWith(
        isLoading: true,
        currentIndex: 0,
        seenProfileIds: const [],
        clearError: true,
      );
    }

    try {
      final page = await repository.getProfilesForDiscovery(
        actorUserId: actorUserId,
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm ?? state.distanceKm,
        minAge: minAge ?? state.minAge,
        maxAge: maxAge ?? state.maxAge,
        limit: 8,
        cursor: cursor ?? (append ? state.nextCursor : null),
      );

      // Filter out the current user's own profile as a client-side safety net.
      final newProfiles = page.profiles
          .where((p) => p.id != actorUserId)
          .toList();
      final mergedProfiles = append
          ? [...state.profiles, ...newProfiles]
          : newProfiles;

      state = state.copyWith(
        profiles: mergedProfiles,
        isLoading: false,
        isLoadingMore: false,
        currentIndex: append ? state.currentIndex : 0,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null && page.profiles.length >= 8,
        distanceKm: distanceKm ?? state.distanceKm,
        minAge: minAge ?? state.minAge,
        maxAge: maxAge ?? state.maxAge,
        latitude: latitude ?? state.latitude,
        longitude: longitude ?? state.longitude,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: _friendlyError(e),
      );
    }
  }

  Future<void> loadNextPage({required String actorUserId}) async {
    await fetchProfiles(
      actorUserId: actorUserId,
      latitude: state.latitude,
      longitude: state.longitude,
      append: true,
    );
  }

  Future<void> likeProfile(String profileId) async {
    _moveToNext(profileId);
  }

  Future<void> passProfile(String profileId) async {
    _moveToNext(profileId);
  }

  void _moveToNext(String profileId) {
    final updatedSeen = [...state.seenProfileIds, profileId];
    final nextIndex = state.currentIndex + 1;

    state = state.copyWith(
      seenProfileIds: updatedSeen,
      currentIndex: nextIndex,
    );
  }

  void resetSwipe() {
    state = state.copyWith(
      currentIndex: 0,
      seenProfileIds: const [],
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      if (error.isNetwork) {
        return 'No internet connection. Check your network and retry.';
      }
      if (error.kind == ApiErrorKind.timeout) {
        return 'Request timed out. Please retry.';
      }
      if (error.isUnauthorized) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.message.trim().isNotEmpty) {
        return error.message;
      }
    }

    final raw = error.toString();
    if (raw.toLowerCase().contains('network')) {
      return 'No internet connection. Check your network and retry.';
    }
    return 'Could not load profiles right now. Please try again.';
  }
}
