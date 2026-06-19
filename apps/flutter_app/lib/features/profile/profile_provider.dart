import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/sources/profile_data_source.dart';
import '../../data/sources/users_data_source.dart';
import '../../domain/models/profile_model.dart';
import '../../core/network/dio_provider.dart';

// Profile Repository Providers
final profileDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return ProfileDataSourceImpl(dio);
});

final profileRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(profileDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});

// Profile Provider
final userProfileProvider = FutureProvider<Profile>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile();
});

// Profile State Provider
final profileStateProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileState {
  final Profile? profile;
  final bool isLoading;
  final String? error;
  final bool isPhotoUploading;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isPhotoUploading = false,
  });

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
    bool? isPhotoUploading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isPhotoUploading: isPhotoUploading ?? this.isPhotoUploading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await repository.getUserProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Profile profile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await repository.updateProfile(profile);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadPhoto(XFile photo) async {
    state = state.copyWith(isPhotoUploading: true, error: null);
    try {
      await repository.uploadProfilePhoto(photo);
      // Reload profile after upload
      await loadProfile();
      state = state.copyWith(isPhotoUploading: false);
    } catch (e) {
      state = state.copyWith(
        isPhotoUploading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteProfilePhoto(photoId);
      // Reload profile after deletion
      await loadProfile();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> syncLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await repository.syncLocation(latitude: latitude, longitude: longitude);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> hideAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.hideAccount();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteAccount();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ============================================================================
// User Profile Detail Providers (viewing other users' profiles)
// ============================================================================

final usersDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return UsersDataSource(dio: dio);
});

/// Get a specific user's public profile by ID (with auto-logging of view).
final userDetailProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final dataSource = ref.watch(usersDataSourceProvider);
  final profile = await dataSource.getUserProfile(userId);
  // Automatically log the view (fire and forget, non-critical)
  await dataSource.logProfileView(userId);
  return profile;
});

/// Log a profile view for a user (fire-and-forget, non-critical).
final logProfileViewProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final dataSource = ref.watch(usersDataSourceProvider);
  await dataSource.logProfileView(userId);
});
