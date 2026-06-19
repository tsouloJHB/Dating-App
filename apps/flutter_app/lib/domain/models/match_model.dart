import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

@freezed
class Match with _$Match {
  const factory Match({
    required String id,
    required String userId,
    required String matchedUserId,
    required DateTime matchedAt,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
}
