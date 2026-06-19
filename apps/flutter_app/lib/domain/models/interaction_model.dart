import 'package:freezed_annotation/freezed_annotation.dart';

part 'interaction_model.freezed.dart';
part 'interaction_model.g.dart';

@freezed
class Interaction with _$Interaction {
  const factory Interaction({
    required String id,
    required String userId,
    required String targetUserId,
    required InteractionType type,
    required DateTime createdAt,
  }) = _Interaction;

  factory Interaction.fromJson(Map<String, dynamic> json) =>
      _$InteractionFromJson(json);
}

enum InteractionType {
  @JsonValue('like')
  like,
  @JsonValue('pass')
  pass,
  @JsonValue('view')
  view,
}
