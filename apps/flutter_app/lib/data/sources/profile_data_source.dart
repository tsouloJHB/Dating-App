import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/profile_model.dart';
import '../../core/constants/api_constants.dart';

abstract class ProfileDataSource {
  Future<Profile> getUserProfile();

  Future<Profile> updateProfile(Profile profile);

  /// Partial profile update (gender, preferredGender, bio, etc.).
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

class ProfileDataSourceImpl implements ProfileDataSource {
  final Dio dio;

  ProfileDataSourceImpl(this.dio);

  @override
  Future<Profile> getUserProfile() async {
    try {
      final response = await dio.get(ApiConstants.accountProfile);
      return Profile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch profile: ${e.message}');
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final response = await dio.put(
        ApiConstants.accountProfile,
        data: profile.toJson(),
      );
      return Profile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    }
  }

  @override
  Future<void> patchAccountProfile(Map<String, dynamic> fields) async {
    try {
      await dio.patch(ApiConstants.accountProfile, data: fields);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    }
  }

  @override
  Future<void> uploadProfilePhoto(XFile photo) async {
    try {
      final fileName = photo.name.isNotEmpty ? photo.name : 'photo.jpg';
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(
          await photo.readAsBytes(),
          filename: fileName,
        ),
      });

      await dio.post(
        ApiConstants.mediaUpload,
        data: formData,
      );
    } on DioException catch (e) {
      throw Exception('Failed to upload photo: ${e.message}');
    }
  }

  @override
  Future<void> deleteProfilePhoto(String photoId) async {
    try {
      await dio.delete(ApiConstants.mediaItem(photoId));
    } on DioException catch (e) {
      throw Exception('Failed to delete photo: ${e.message}');
    }
  }

  @override
  Future<void> reorderProfilePhotos(List<String> orderedMediaIds) async {
    try {
      await dio.patch(
        ApiConstants.mediaReorder,
        data: {'orderedIds': orderedMediaIds},
      );
    } on DioException catch (e) {
      throw Exception('Failed to reorder photos: ${e.message}');
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await dio.post(ApiConstants.accountOnboardingComplete);
    } on DioException catch (e) {
      throw Exception('Failed to complete onboarding: ${e.message}');
    }
  }

  @override
  Future<void> updateUserDisplay({String? name, String? image}) async {
    if (name == null && image == null) {
      return;
    }
    try {
      await dio.patch(
        ApiConstants.accountUser,
        data: {
          if (name != null) 'name': name,
          if (image != null) 'image': image,
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to update account: ${e.message}');
    }
  }

  @override
  Future<void> syncLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await dio.put(
        ApiConstants.accountProfile,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to sync location: ${e.message}');
    }
  }

  @override
  Future<void> hideAccount() async {
    try {
      await dio.patch(ApiConstants.accountHide);
    } on DioException catch (e) {
      throw Exception('Failed to hide account: ${e.message}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await dio.delete(ApiConstants.accountDelete);
    } on DioException catch (e) {
      throw Exception('Failed to delete account: ${e.message}');
    }
  }
}
