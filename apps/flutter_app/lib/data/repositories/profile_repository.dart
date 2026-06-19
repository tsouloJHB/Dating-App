import 'package:image_picker/image_picker.dart';

import '../sources/profile_data_source.dart';
import '../../domain/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Profile> getUserProfile();

  Future<Profile> updateProfile(Profile profile);

  Future<void> patchAccountProfile(Map<String, dynamic> fields);

  Future<void> uploadProfilePhoto(XFile photo);

  Future<void> deleteProfilePhoto(String photoId);

  Future<void> reorderProfilePhotos(List<String> orderedMediaIds);

  Future<void> completeOnboarding();

  Future<void> updateUserDisplay({String? name, String? image});

  Future<void> syncLocation({
    required double latitude,
    required double longitude,
  });

  Future<void> hideAccount();

  Future<void> deleteAccount();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<Profile> getUserProfile() async {
    final profile = await dataSource.getUserProfile();
    return profile.normalizedDiscoverySettings();
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final updatedProfile = await dataSource.updateProfile(
      profile.normalizedDiscoverySettings(),
    );
    return updatedProfile.normalizedDiscoverySettings();
  }

  @override
  Future<void> patchAccountProfile(Map<String, dynamic> fields) =>
      dataSource.patchAccountProfile(fields);

  @override
  Future<void> uploadProfilePhoto(XFile photo) =>
      dataSource.uploadProfilePhoto(photo);

  @override
  Future<void> deleteProfilePhoto(String photoId) =>
      dataSource.deleteProfilePhoto(photoId);

  @override
  Future<void> reorderProfilePhotos(List<String> orderedMediaIds) =>
      dataSource.reorderProfilePhotos(orderedMediaIds);

  @override
  Future<void> completeOnboarding() => dataSource.completeOnboarding();

  @override
  Future<void> updateUserDisplay({String? name, String? image}) =>
      dataSource.updateUserDisplay(name: name, image: image);

  @override
  Future<void> syncLocation({
    required double latitude,
    required double longitude,
  }) =>
      dataSource.syncLocation(latitude: latitude, longitude: longitude);

  @override
  Future<void> hideAccount() => dataSource.hideAccount();

  @override
  Future<void> deleteAccount() => dataSource.deleteAccount();
}
