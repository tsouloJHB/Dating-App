import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String userId,
    required String bio,
    required int minAgeRange,
    required int maxAgeRange,
    required int discoveryRadius,
    required String preferredGender,
    required List<String> interests,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

extension ProfileDiscoverySettingsNormalization on Profile {
  Profile normalizedDiscoverySettings() {
    final normalizedMinAge = _clampInt(minAgeRange, 18, 80);
    final normalizedMaxAge = _clampInt(maxAgeRange, 18, 80);
    final lowerAge = normalizedMinAge <= normalizedMaxAge
        ? normalizedMinAge
        : normalizedMaxAge;
    final upperAge = normalizedMinAge <= normalizedMaxAge
        ? normalizedMaxAge
        : normalizedMinAge;

    return copyWith(
      minAgeRange: lowerAge,
      maxAgeRange: upperAge,
      discoveryRadius: _clampInt(discoveryRadius, 1, 500),
    );
  }
}

int _clampInt(int value, int min, int max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
